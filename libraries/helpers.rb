#
# Cookbook:: chef_vault_retry
# Library:: helpers
#
# Copyright:: 2017, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module ChefVaultRetryCookbook
  # Helper method for retrieving a chef-vault item
  # If the node doesn't have access to the chef-vault item yet, output a message
  # and retry on a configurable interval
  def chef_vault_retry_item(v, i)
    if ChefVault::Item.vault?(v, i)
      node['chef_vault_retry']['retries'].times do
        begin
          return ChefVault::Item.load(v, i)
        rescue ChefVault::Exceptions::SecretDecryption
          puts "Unable to decrypt vault item (#{v}/#{i})."\
            " Retrying in #{node['chef_vault_retry']['interval']}s."
          sleep node['chef_vault_retry']['interval']
          next
        end
      end
      raise "Failed to decrypt #{v}/#{i}"
    elsif node['chef_vault_retry']['databag_fallback']
      Chef::DataBagItem.load(v, i)
    else
      raise "#{v}/#{i} vault item not found and databag_fallback not permitted"
    end
  end
end

Chef::Recipe.send(:include, ChefVaultRetryCookbook)
Chef::Resource.send(:include, ChefVaultRetryCookbook)
Chef::Provider.send(:include, ChefVaultRetryCookbook)
