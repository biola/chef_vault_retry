# chef_vault_retry

This cookbook is heavily inspired by the excellent [chef-vault cookbook](https://supermarket.chef.io/cookbooks/chef-vault). In similar fashion, it installs the chef-vault gem and provides a helper method for retrieving vault item contents. Unlike the `chef-client` cookbook however, the `chef_vault_retry_item` helper method will periodically retry loading the vault item if a `ChefVault::Exceptions::SecretDecryption` exception is raised, allowing an admin to refresh the vault item before the chef-client run fails. This is primarily intended to ease the bootstrapping of new systems.

## Helper Methods

This cookbook provides a helper method for retrieving chef-vault items:

```
secret = chef_vault_retry_item('vault', 'item')
```

See the Usage section below for more details. Similar to the `chef-client` cookbook, if the item isn't encrypted and the `node['chef_vault_retry']['databag_fallback']` attribute is set to `true` (the default), this helper method will attempt to load the item as a regular data bag item.

## Attributes

* `node['chef_vault_retry']['interval']` - the interval in seconds between retries; default is `30`
* `node['chef_vault_retry']['retries']` - the maximum number of retries before allowing the chef-client run to fail; default is `40`

The following attributes have been duplicated from the `chef-client` cookbook for gem installation:

* `node['chef_vault_retry']['version']` - version of the `chef-client` gem to install; default is unset and will use the version of chef-vault included with modern versions of Chef
* `node['chef_vault_retry']['databag_fallback']` - If the vault item passed is a regular data bag item, fall back to loading it as such; default is `true`
* `node['chef_vault_retry']['gem_source']` - maps to the `source` property for the `chef_gem` resource; default is `nil`
* `node['chef_vault_retry']['gem_options']` - maps to the `options` property for the `chef_gem` resource; default is `nil`

## Usage

For Chef 12 nodes, include the `chef_vault_retry::default` recipe in the node's run list before using the helper method in recipes. For newer Chef versions, the `chef-vault` gem is installed by default and this step can be skipped.

Load a secret from a chef-vault item:

```
secret = chef_vault_retry_item('vault', 'item')
```

If a node is unable to decrypt an existing chef-vault item, the following error will be displayed in the chef-client run and will repeat on the configured interval (default 30s):

```
Unable to decrypt vault item (vault/item). Retrying in 30s.
```

Assuming an admin refreshes the vault item before the configured maximum number of retries (default 40), the chef-client run will continue now that the node can decrypt the item's contents.
