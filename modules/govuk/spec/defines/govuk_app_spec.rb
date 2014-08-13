require_relative '../../../../spec_helper'

describe 'govuk::app', :type => :define do
  let(:title) { 'giraffe' }
  let(:hiera_data) {{
      'app_domain'            => 'test.gov.uk',
      'asset_root'            => 'https://static.test.gov.uk',
      'website_root'          => 'foo.test.gov.uk',
      'aws_ses_smtp_host'     => 'email-smtp.aws.example.com',
      'aws_ses_smtp_username' => 'a_username',
      'aws_ses_smtp_password' => 'a_password',
    }}

  context 'with no params' do
    it do
      expect {
        should contain_file('/var/apps/giraffe')
      }.to raise_error(Puppet::Error, /Must pass app_type/)
    end
  end

  context 'with good params' do
    let(:params) do
      {
        :port => 8000,
        :app_type => 'rack',
      }
    end

    it do
      should contain_govuk__app__package('giraffe').with(
        'vhost_full' => 'giraffe.test.gov.uk',
      )
      should contain_govuk__app__config('giraffe').with(
        'domain' => 'test.gov.uk',
      )
      should contain_service('giraffe').with_provider('upstart')
    end

    it "should hide the Raindrops and Sidekiq monitoring endpoint" do
      should contain_govuk__app__nginx_vhost('giraffe').with(
        'hidden_paths' => ['/_raindrops', '/sidekiq']
      )
    end
  end

  context 'app_type => bare, without command' do
    let(:params) {{
      :app_type => 'bare',
      :port     => 123,
    }}

    it { expect { should }.to raise_error(Puppet::Error, /Invalid \$command parameter/) }
  end

  describe 'app_type => bare, which logs JSON to STDERR' do
    let(:params) {{
      :app_type           => 'bare',
      :port               => 123,
      :command            => '/bin/yes',
      :log_format_is_json => true,
    }}

    it { should contain_govuk__logstream("#{title}-app-err").with("json" => true) }
  end

  context 'health check hidden' do
    let(:params) do
      {
        :app_type => 'rack',
        :port => 8000,
        :health_check_path => '/healthcheck',
        :expose_health_check => false,
      }
    end

    it "should hide the Raindrops, Sidekiq monitoring and healthcheck paths" do
      should contain_govuk__app__nginx_vhost('giraffe').with(
        'hidden_paths' => ['/_raindrops', '/sidekiq', '/healthcheck']
      )
    end
  end

  context 'health check path not provided, health check hidden' do
    let(:params) do
      {
        :app_type => 'rack',
        :port => 8000,
        :expose_health_check => false,
      }
    end

    it "should fail to compile" do
      expect { should }.to raise_error(Puppet::Error, /Cannot hide/)
    end
  end

  context 'with ensure' do
    context 'ensure => absent' do
      let(:params) {{
        :app_type => 'rack',
        :port => 8000,
        :ensure => 'absent',
      }}

      it do
        should contain_govuk__app__package('giraffe').with_ensure('absent')
      end
    end

    context 'ensure => true' do
      let(:params) {{
        :app_type => 'rack',
        :port => 8000,
        :ensure => 'true',
      }}

      it { expect { should }.to raise_error(Puppet::Error, /Invalid ensure value/) }
    end
    
    context 'ensure => false' do
      let(:params) {{
        :app_type => 'rack',
        :port => 8000,
        :ensure => 'false',
      }}

      it { expect { should }.to raise_error(Puppet::Error, /Invalid ensure value/) }
    end
  end
end
