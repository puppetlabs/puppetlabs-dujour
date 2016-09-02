require 'spec_helper'

describe 'dujour' do
  let(:facts) do { :fqdn => 'localhost' } end

  it { should contain_hocon_setting('global.logging-config').with_value('/etc/puppetlabs/dujour/logback.xml') }

  it { should contain_hocon_setting('webserver.host').with_value('localhost') }
  it { should contain_hocon_setting('webserver.port').with_value('9999') }


  it { should contain_hocon_setting('database.classname').with_value('org.postgresql.Driver') }
  it { should contain_hocon_setting('database.subprotocol').with_value('postgresql') }
  it { should contain_hocon_setting('database.subname').with_value('//localhost:5432/dujour') }
  it { should contain_hocon_setting('database.username').with_value('dujour') }
  it { should contain_hocon_setting('database.password').with_value('dujour') }
end
