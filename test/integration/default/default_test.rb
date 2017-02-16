# # encoding: utf-8

# Inspec test for recipe chef_vault_retry::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/tmp/secret_password') do
  it { should exist }
  its('content') { should eq 'supersecretpassword' }
end
