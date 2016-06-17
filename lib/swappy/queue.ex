defmodule Swappy.Queue do
  # This strategy is "go until everything is done". Other possible strategies to implement later
  #  - go until enough, then drop everything else on the floor
  #  - go until enough, wait for remaining workers, return answers and partials so we can continue later

  def process(job) do
    Swappy.Queue.Manager.start(self, job)
    receive do
      {:results, raw_anagrams} -> raw_anagrams
    end
  end

  defmodule Manager do
   # You would think more would be faster, but you'd be wrong. I don't know why, really.
    @max_workers 4

    def start(spawner_pid, first_job) do
      spawn_link fn ->
        manage_queue(spawner_pid, [], [first_job], spawn_workers)
      end
    end

    defp spawn_workers do
      1..@max_workers |> Enum.map(fn _ -> spawn_link &(Swappy.Queue.Worker.work/0) end)
    end

    # all done, yaaaay!
    defp manage_queue(spawner_pid, results, []=_jobs, idle_workers) when length(idle_workers) == @max_workers do
      send(spawner_pid, {:results, results})
    end

    # can assign work
    defp manage_queue(spawner_pid, results, [job|jobs_t], [idle_worker|idle_workers_t]) do
      send(idle_worker, {:job, self, job})
      manage_queue(spawner_pid, results, jobs_t, idle_workers_t)
    end

    # can't assign work
    defp manage_queue(spawner_pid, results, jobs, idle_workers) do
      receive do
        {:worker_results, new_anagrams, new_jobs, worker_pid} ->
          manage_queue(spawner_pid, results ++ new_anagrams, new_jobs ++ jobs, [worker_pid|idle_workers])
      end
    end
  end

  defmodule Worker do
    def work() do
      receive do
        {:job, queue_pid, job} ->
          {anagrams, jobs} = do_work([job], [], 0)
          send(queue_pid, {:worker_results, anagrams, jobs, self})
      end
      work()
    end

    # here be dragons
    @max_batch_size 100_000
    defp do_work([], found_anagrams, _completed_jobs) do
      {found_anagrams, []}
    end
    defp do_work(jobs, found_anagrams, @max_batch_size=_completed_jobs) do
      {found_anagrams, jobs}
    end
    defp do_work([job|jobs_t], found_anagrams, completed_jobs) do
      case Swappy.process_one_job(job) do
        {:anagram, anagram} ->
          do_work(jobs_t, [anagram|found_anagrams], completed_jobs+1)
        {:more_jobs, jobs} ->
          do_work(jobs ++ jobs_t, found_anagrams, completed_jobs+1)
      end
    end
  end

end
