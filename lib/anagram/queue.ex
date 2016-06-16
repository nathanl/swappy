defmodule Anagram.Queue do
 # You would think more would be faster, but you'd be wrong. I don't know why, really.
  @max_workers 4

  # This strategy is "go until everything is done". Other possible strategies to implement later
  #  - go until enough, then drop everything else on the floor
  #  - go until enough, wait for remaining workers, return answers and partials so we can continue later

  def process(job) do
    spawner_pid = self
    idle_workers = 1..@max_workers |> Enum.map(fn _ -> spawn_link &(work/0) end)
    spawn_link fn ->
      manage_queue(spawner_pid, [], [job], idle_workers)
    end
    receive do
      {:results, raw_anagrams} -> raw_anagrams
    end
  end

  # all done, yaaaay!
  def manage_queue(spawner_pid, results, []=_jobs, idle_workers) when length(idle_workers) == @max_workers do
    send(spawner_pid, {:results, results})
  end

  # can assign work
  def manage_queue(spawner_pid, results, [job|jobs_t], [idle_worker|idle_workers_t]) do
    send(idle_worker, {:job, self, job})
    manage_queue(spawner_pid, results, jobs_t, idle_workers_t)
  end

  # can't assign work
  def manage_queue(spawner_pid, results, jobs, idle_workers) do
    receive do
      {:worker_results, new_anagrams, new_jobs, worker_pid} ->
        manage_queue(spawner_pid, results ++ new_anagrams, new_jobs ++ jobs, [worker_pid|idle_workers])
    end
  end

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
  def do_work([], found_anagrams, _completed_jobs) do
    {found_anagrams, []}
  end
  def do_work(jobs, found_anagrams, @max_batch_size=_completed_jobs) do
    {found_anagrams, jobs}
  end
  def do_work([job|jobs_t], found_anagrams, completed_jobs) do
    case Anagram.process_one_job(job) do
      {:anagram, anagram} ->
        do_work(jobs_t, [anagram|found_anagrams], completed_jobs+1)
      {:more_jobs, jobs} ->
        do_work(jobs ++ jobs_t, found_anagrams, completed_jobs+1)
    end
  end

end
