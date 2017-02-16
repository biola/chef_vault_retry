include_recipe 'chef_vault_retry::default'

item = chef_vault_retry_item('vault', 'item')

file '/tmp/secret_password' do
  content item['password']
end
