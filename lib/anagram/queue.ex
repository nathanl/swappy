defmodule Anagram.Queue do
  @max_workers 8

  # start queue process
  # send it top-level job
  #   queue process does this:
  #     if counter 0 and no jobs left, return results
  #     if counter at max, listen for answers and worker dead
  #     if counter not at max, also listen for jobs
  #     when receive a job, spawn a worker for it and inc counter and recurse
  #     when receive an answer, add to acc and recurse
  #     when receive a "worker dead", dec counter, recurse
  #
  # strategies
  #   - go until everything done
  #   - go until enough, then drop everything on the floor
  #   - go until enough, wait for remaining workers, return answers and partials

  def process(job) do
    spawner_pid = self
    spawn_link fn ->
      manage_queue(spawner_pid, [], [job], 0)
    end
    receive do
      [:results, results] -> results
    end
  end

  def manage_queue(spawner_pid, results, jobs, worker_count) do
    if worker_count == @max_workers do
      receive do
        :worker_dead ->
          manage_queue(spawner_pid, results, jobs, worker_count - 1)
        {:anagram, found} ->
          manage_queue(spawner_pid, [found|results], jobs, worker_count)
        {:anagram, found} ->
          manage_queue(spawner_pid, [found|results], jobs, worker_count)
      end
    else
      receive do
        :worker_dead ->
          manage_queue(spawner_pid, results, jobs, worker_count - 1)
        {:anagram, found} ->
          manage_queue(spawner_pid, [found|results], jobs, worker_count)
        {:anagram, found} ->
          manage_queue(spawner_pid, [found|results], jobs, worker_count)
        'heres a job' ->
          queue_pid = self
          spawn_link fn ->
            results = process_one_job
          end
          manage_queue(spawner_pid, results, jobs, worker_count + 1)
      end
    # worker_count == 0 and mah-mailbox-be-empty  -> # after N ms...
    #   send(spawner_pid, [:results, results])
    # end
  end

    job = [found: [], possible_words: possible_words, bag: bag]
    result = Anagram.Queue.process(job)



end
