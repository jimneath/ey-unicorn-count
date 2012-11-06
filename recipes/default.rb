if ['app_master', 'app', 'solo'].include?(node[:instance_role])
  node[:applications].each do |app_name, _| 
    # unicorn conf
    execute "update unicorn.rb" do
      command "sed -ire '/^worker_processes/{s/.*/worker_processes #{node[:unicorn_worker_count]}/}' /data/#{app_name}/shared/config/unicorn.rb"
    end

    # unicorn monitrc
    template "/etc/monit.d/unicorn_#{app_name}.monitrc" do
      source 'unicorn.monitrc.erb'
      owner 'deploy'
      group 'deploy'
      mode 0644
      backup false
      variables({
        :app_name => app_name,
        :worker_count => node[:unicorn_worker_count]
      })
    end
  
    # reload monit
    execute "monit reload"
  end
end