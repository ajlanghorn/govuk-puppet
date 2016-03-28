require_relative '../../../../spec_helper'

describe 'govuk_crawler', :type => :class do

  let(:default_params) {{
    :mirror_root => '/foo',
  }}

  let(:params) {
    default_params
  }

  it { is_expected.to contain_file('/usr/local/bin/govuk_sync_mirror') }

  it { is_expected.to contain_file('/foo/error') }

  it {
    # Leaky abstraction? We need to know that govuk_user creates the
    # parent directory for our file.
    is_expected.to contain_file('/home/govuk-crawler/.ssh').with_ensure('directory')
  }

  it {
    is_expected.to contain_file('/home/govuk-crawler/.ssh/id_rsa').with_ensure('file')
  }

  describe "seed_enable" do
    context "false (default)" do
      it { is_expected.to contain_file('/etc/cron.d/seed-crawler').with_ensure('absent') }
    end

    context "true" do
      let(:params) {
        default_params.merge({
          :seed_enable => true,
        })
      }

      it { is_expected.to contain_file('/etc/cron.d/seed-crawler').with_ensure('present') }
    end
  end

  describe "sync_enable" do
    context "false (default)" do
      it { is_expected.to contain_cron('sync-to-mirror').with_ensure('absent') }
    end

    context "true" do
      let(:params) {
        default_params.merge({
          :sync_enable => true,
        })
      }

      it { is_expected.to contain_cron('sync-to-mirror').with_ensure('present') }
    end
  end

  describe "targets" do
    context "[] (default)" do
      it { is_expected.to contain_file('/usr/local/bin/govuk_sync_mirror').with_content(/^TARGETS=""$/) }
    end

     context "string" do
       let(:params) {
         default_params.merge({
           :targets => 'user102@mirror102',
         })
       }

       it { is_expected.to raise_error(Puppet::Error, /is not an Array/) }
    end

     context "array of items" do
       let(:params) {
         default_params.merge({
           :targets => ['user101@mirror101', 'user102@mirror102'],
         })
       }
       it { is_expected.to contain_file('/usr/local/bin/govuk_sync_mirror').with_content(/^TARGETS="user101@mirror101 user102@mirror102"$/) }
     end
  end

  describe "ssh_keys" do
    context "{} (default)" do
      it { is_expected.to have_sshkey_resource_count(0)  }
    end

    context "string" do
      let(:params) {
        default_params.merge({
          :ssh_keys => 'mirror102',
        })
      }

      it { is_expected.to raise_error(Puppet::Error, /is not a Hash/) }
    end

    context "hash of keys" do
      let(:params) {
        default_params.merge({
          :ssh_keys => {
            'mirror101' => {
              'type' => 'ssh-rsa',
              'key'  => 'testkey1',
            },
            'mirror102' => {
              'type' => 'ssh-rsa',
              'key'  => 'testkey2',
            },
          }
        })
      }

      it {
        is_expected.to have_sshkey_resource_count(2)
        is_expected.to contain_sshkey('mirror101').with(
          :type => 'ssh-rsa',
          :key  => 'testkey1',
        )
        is_expected.to contain_sshkey('mirror102').with(
          :type => 'ssh-rsa',
          :key  => 'testkey2',
        )
      }
    end
  end
end
