if ['app_master', 'app', 'solo'].include?(node[:instance_role])
  node[:applications].each do |app_name, _| 
    # restart unicorn
    execute "restart-unicorn" do
      command "monit reload && sleep 20 && monit restart unicorn_master_#{app_name}"
      action :nothing
    end
    
    # unicorn conf
    execute "update unicorn.rb" do
      command "sed -ire '/^worker_processes/{s/.*/worker_processes #{node[:unicorn_worker_count]}/}' /data/#{app_name}/shared/config/unicorn.rb"
    end

    # unicorn monitrc
    template "/etc/monit.d/unicorn_#{app_name}.monitrc" do
      source 'unicorn.monitrc.erb'
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      backup false
      variables({
        :app_name => app_name,
        :worker_count => node[:unicorn_worker_count],
        :user => node[:owner_name],
        :group => node[:owner_name],
      })
      notifies :run, resources(:execute => "restart-unicorn"), :delayed
    end
  end
end