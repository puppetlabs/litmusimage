# output task execution
unless Rake.application.options.trace
  setup = ->(task, *_args) do
    puts "\e[36m==> rake #{task}\e[0m"
  end

  task :log_hooker do
    Rake::Task.tasks.reject { |t| t.to_s == 'log_hooker' }.each do |a_task|
      a_task.actions.prepend(setup)
    end
  end
  Rake.application.top_level_tasks.prepend(:log_hooker)
end

# serial acceptance task
namespace :litmus do
  desc "Run tests against all nodes in the litmus inventory\n(defaults: tag=nil)"
  task :acceptance, [:tag] do |_task, args|
    args.with_defaults(tag: nil)

    Rake::Task.tasks.select { |t| t.to_s =~ %r{^litmus:acceptance:(?!(localhost|parallel)$)} }.each do |litmus_task|
      puts "Running task #{litmus_task}"
      litmus_task.invoke(*args)
    end
  end
end
