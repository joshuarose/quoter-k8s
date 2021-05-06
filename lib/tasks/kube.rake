# lib/tasks/kube.rake

# Turn off Rake noise
Rake.application.options.trace = false

namespace :kube do
  desc 'Print useful information aout our Kubernete setup'
  task :list do
    kubectl 'get all --all-namespaces'
  end

  def kubectl(command)
    puts `kubectl #{command}`
  end
end