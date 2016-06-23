defmodule Swappy.Queue do
  # This strategy is "go until everything is done". Other possible strategies to implement later
  #  - go until enough, then drop everything else on the floor
  #  - go until enough, wait for remaining workers, return answers and partials so we can continue later

  def process(job, options) do
    limit = Map.get(options, :limit, :infinity)
    Swappy.Queue.Manager.start(self, job, %{limit: limit})
    receive do
      {:results, raw_anagrams} -> raw_anagrams
    end
  end

  defmodule Manager do
   # You would think "as many workers as I have cores" would be optimal, but in my testing, it's fewer than that.
   # I'm not sure why.
   # TODO - make configurable
    @worker_count 4

    def start(spawner_pid, first_job, %{limit: limit}) do
      spawn_link fn ->
        manage_queue(
          spawner_pid, [], [first_job], spawn_workers, result_count = 0, limit
        )
      end
    end

    defp spawn_workers do
      1..@worker_count |> Enum.map(fn _ -> spawn_link &(Swappy.Queue.Worker.work/0) end)
    end

    # done because reached limit, yay!
    defp manage_queue(spawner_pid, results, job, idle_workers, result_count, limit) when result_count >= limit do
      send(spawner_pid, {:results, results})
    end

    # done because nothing left to do, yay!
    defp manage_queue(spawner_pid, results, []=_jobs, idle_workers, result_count, limit) when length(idle_workers) == @worker_count do
      send(spawner_pid, {:results, results})
    end

    # can assign work
    defp manage_queue(spawner_pid, results, [job|jobs_t], [idle_worker|idle_workers_t], result_count, limit) do
      send(idle_worker, {:job, self, job, result_count, limit})
      manage_queue(spawner_pid, results, jobs_t, idle_workers_t, result_count, limit)
    end

    # can't assign work
    defp manage_queue(spawner_pid, results, jobs, idle_workers, result_count, limit) do
      receive do
        {:worker_results, new_anagrams, new_jobs, worker_pid} ->
          new_result_count = length(new_anagrams) + result_count
          manage_queue(spawner_pid, results ++ new_anagrams, new_jobs ++ jobs, [worker_pid|idle_workers], new_result_count, limit)
      end
    end
  end

  defmodule Worker do
    def work() do
      receive do
        {:job, queue_pid, job, result_count, limit} ->
          {anagrams, jobs} = do_work([job], [], 0, result_count, limit)
          send(queue_pid, {:worker_results, anagrams, jobs, self})
      end
      work()
    end

    # here be dragons
    @max_batch_size 100_000
    defp do_work([], found_anagrams, _completed_jobs, result_count, limit) do
      {found_anagrams, []}
    end
    defp do_work(jobs, found_anagrams, @max_batch_size=_completed_jobs, result_count, limit) do
      {found_anagrams, jobs}
    end
    defp do_work(jobs, found_anagrams, _completed_job, result_count, limit) when result_count == limit do
      {found_anagrams, jobs}
    end
    defp do_work([job|jobs_t], found_anagrams, completed_jobs, result_count, limit) do
      case Swappy.process_one_job(job) do
        {:anagram, anagram} ->
          do_work(jobs_t, [anagram|found_anagrams], completed_jobs+1, result_count + 1, limit)
        {:more_jobs, jobs} ->
          # The fact that new jobs are added to the front, and that the new ones should be
          # sorted like the incoming wordlist, should mean that the next job to work is
          # always the one with the highest-priority available word
          do_work(jobs ++ jobs_t, found_anagrams, completed_jobs+1, result_count, limit)
      end
    end
  end

end
