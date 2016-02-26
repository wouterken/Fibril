
fibers = []

tasks = 0
start = Time.now
ends = nil

i = 50
run_event = ->{
  puts "Starting"
  fiber = nil
  fiber = Fiber.new do
    puts "Resumed"
    tasks += 1
    Thread.new{
      fibers << fiber
      tasks -= 1
    }
    Fiber.yield
    ends = Time.now
    puts "Thread took #{ends - start}"
    i -= 1
    fibers << run_event if i >= 0
  end
  puts "Adding starting fiber #{fiber}"
  fibers << fiber
}

fibers << run_event

while fibers.any? || !tasks.zero?

  task = fibers.any? ? fibers.shift : nil
  case task
  when Proc
    puts "Task is proc"
    task[]
  when Fiber
    puts "Task is fiber #{task}"
    task.resume
  else
    puts "Task is nil"
  end
end

