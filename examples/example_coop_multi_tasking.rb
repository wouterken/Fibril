require_relative "../lib/fibril/loop"


def long_running_task
  sleep 1
  puts "Part 1 of long running task"
  Fibril.current.tick
  sleep 1
  puts "Part 2 of long running task"
  Fibril.current.tick
  sleep 1
  puts "Part 3 of long running task"
  Fibril.current.tick
  sleep 1
  puts "Part 4 of long running task"
  Fibril.current.tick
end

fibril.long_running_task

fibril(:short_task_one){
  puts "I'm a short task"
}

fibril(:short_task_one){
  puts "I'm also a short task"
}

await(:short_task_one){
  fibril(:short_task_three){
    puts "I'm a third short task"
  }
}

