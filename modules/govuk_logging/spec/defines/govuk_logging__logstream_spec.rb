require_relative '../../../../spec_helper'

describe 'govuk_logging::logstream', :type => :define do
  let(:default_shipper) { 'redis,\$REDIS_SERVERS,key=logs,bulk=true,bulk_index=logs-current' }
  let(:default_filters) { 'init_txt,add_timestamp,add_source_host' }
  let(:title) { 'giraffe' }
  let(:facts) {{ :fqdn => 'camel.example.com' }}

  let(:log_file) { '/var/log/elephant.log' }
  let(:upstart_conf) { '/etc/init/logstream-giraffe.conf' }

  context 'with default args, ensure => present' do
    let(:params) { {
      :logfile => log_file,
      :ensure  => 'present',
    } }

    it 'should tail correct logfile' do
      is_expected.to contain_file(upstart_conf).with(
        :content => /^\s+tail -F \/var\/log\/elephant\.log \| logship/,
      )
    end

    it 'should pass appropriate CLI args' do
      is_expected.to contain_file(upstart_conf).with(
        :content => /\| logship -f #{default_filters} -s #{default_shipper}$/,
      )
    end
  end

  context 'with invalid ensure args' do
    context 'ensure => true' do
      let(:params) { {
        :logfile => log_file,
        :ensure  => 'true',
      } }
      it 'should fail validation' do
        is_expected.to raise_error(Puppet::Error, /validate_re/)
      end
    end
    context 'ensure => false' do
      let(:params) { {
        :logfile => log_file,
        :ensure  => 'false',
      } }
      it 'should fail validation' do
        is_expected.to raise_error(Puppet::Error, /validate_re/)
      end
    end
  end

  context 'with tags => Array' do
    let(:params) { {
      :logfile => log_file,
      :ensure  => 'present',
      :tags    => ['zebra', 'llama'],
    } }

    it 'should pass add_tags with list in filter chain' do
      is_expected.to contain_file(upstart_conf).with(
        :ensure  => 'present',
        :content => /\| logship -f #{default_filters},add_tags:zebra:llama -s #{default_shipper}$/,
      )
    end
  end

  context 'with fields => Hash' do
    let(:params) { {
      :logfile => log_file,
      :ensure  => 'present',
      :fields  => {'zebra' => 'stripey', 'llama' => 'fluffy'},
    } }

    it 'should pass --fields with kv pairs' do
      is_expected.to contain_file(upstart_conf).with(
        :ensure  => 'present',
        :content => /\| logship -f #{default_filters},add_fields:zebra=stripey:llama=fluffy -s #{default_shipper}$/,
      )
    end
  end

  context 'with json => true' do
    let(:params) { {
      :logfile => log_file,
      :ensure  => 'present',
      :json    => true,
    } }

    it 'should pass --json arg' do
      is_expected.to contain_file(upstart_conf).with(
        :ensure  => 'present',
        :content => /\| logship -f init_json,add_timestamp,add_source_host -s #{default_shipper}$/,
      )
    end
  end

  context 'with statsd counter shipper specified' do
    let(:params) { {
      :logfile       => log_file,
      :ensure        => 'present',
      :json          => true,
      :statsd_metric => 'tom_jerry.foo.%{@fields.bar}',
    } }

    it 'should pass statsd_counter arg' do
      is_expected.to contain_file(upstart_conf).with(
        :ensure  => 'present',
        :content => /\| logship -f init_json,add_timestamp,add_source_host -s #{default_shipper} statsd_counter,metric=tom_jerry.foo.%{@fields.bar}$/,
      )
    end
  end

  context 'with statsd timers specified' do
    let(:params) { {
      :logfile       => log_file,
      :ensure        => 'present',
      :json          => true,
      :statsd_timers => [{'metric' => 'tom_jerry.foo','value' => '@fields.foo'},
                         {'metric' => 'tom_jerry.bar','value' => '@fields.bar'}],
    } }

    it 'should pass statsd_timer arg' do
      is_expected.to contain_file(upstart_conf).with(
        :ensure  => 'present',
        :content => /\| logship -f init_json,add_timestamp,add_source_host -s #{default_shipper} statsd_timer,metric=tom_jerry.foo,timed_field=@fields.foo statsd_timer,metric=tom_jerry.bar,timed_field=@fields.bar$/,
      )
    end
  end

  context 'with json set to false' do
    let(:params) { {
      :logfile       => log_file,
      :ensure        => 'present',
      :json          => false,
      :statsd_timers => [{'metric' => 'tom_jerry.foo','value' => '@fields.foo'},
                         {'metric' => 'tom_jerry.bar','value' => '@fields.bar'}],
      } }
    it 'should not pass through statsd values' do
      is_expected.to contain_file(upstart_conf).with(
        :ensure  => 'present',
        :content => /\| logship -f init_txt,add_timestamp,add_source_host -s #{default_shipper}$/,
        )
    end
  end
end
