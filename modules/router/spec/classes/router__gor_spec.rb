require_relative '../../../../spec_helper'

describe 'router::gor', :type => :class do
  let(:params) {{
    :replay_targets => replay_targets,
  }}
  let(:args_default) {{
    '-input-raw'          => 'localhost:7999',
    '-output-http-method' => %w{GET HEAD OPTIONS},
  }}

  context 'no targets defined (disabled)' do
    let(:replay_targets) {{}}

    it { is_expected.to contain_class('govuk_gor').with({ :enable => false, }) }
  end

  context 'a target defined (enabled)' do
    let(:target_host) { 'replay-target' }
    let(:replay_targets) {{
      target_host => { 'ip' => '127.0.0.1' }
    }}

    it { is_expected.to contain_host(target_host).with_ensure('present') }

    it {
      is_expected.to contain_class('govuk_gor').with(
        :enable => true,
        :args   => args_default.merge({
          '-output-http' => ["https://#{target_host}"],
        }),
      )
    }
  end

  context 'a multiple targets defined (enabled)' do
    let(:target_host_a) { 'replay-target-a' }
    let(:target_host_b) { 'replay-target-b' }
    let(:replay_targets) {{
      target_host_a => { 'ip' => '127.0.0.1' },
      target_host_b => { 'ip' => '127.0.0.2' },
    }}

    it {
      is_expected.to contain_class('govuk_gor').with(
        :enable => true,
        :args   => args_default.merge({
          '-output-http' => ["https://#{target_host_a}", "https://#{target_host_b}"],
        }),
      )
    }
  end
end
