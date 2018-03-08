shared_examples_for 'a openSUSE stemcell' do

  describe command('ls -1 /lib/modules | wc -l') do
    its(:stdout) {should eq "1\n"}
  end

  context 'installed by image_install_grub' do
    describe file('/etc/fstab') do
      it { should be_file }
      its(:content) { should match 'UUID=' }
      its(:content) { should match '/ ext4 defaults 1 1' }
    end

    # GRUB 2 configuration
    describe file('/boot/grub2/grub.cfg') do
      its(:content) { should match 'net.ifnames=0' }
      its(:content) { should match 'selinux=0' }
      its(:content) { should match 'plymouth.enable=0' }
      its(:content) { should_not match 'xen_blkfront.sda_is_xvda=1' }
      it('single-user mode boot should be disabled (stig: V-38586)') do
        expect(subject.content).to_not match 'single'
      end

      it('should set the user name and password for grub menu (stig: V-38585)') do
        expect(subject.content).to match 'set superusers=vcap'
      end
      it('should set the user name and password for grub menu (stig: V-38585)') do
        expect(subject.content).to match /^password_pbkdf2 vcap grub.pbkdf2.sha512.*/
      end

      it('should be of mode 600 (stig: V-38583)') { should be_mode(0600) }
      it('should be owned by root (stig: V-38579)') { should be_owned_by('root') }
      it('should be grouped into root (stig: V-38581)') do
        expect(subject.group).to eq('root')
      end
    end

    # GRUB 0.97 configuration (used only on Amazon PV hosts) must have same kernel params as GRUB 2
    describe file('/boot/grub/grub.conf') do
      its(:content) { should match 'net.ifnames=0' }
      its(:content) { should match 'selinux=0' }
      its(:content) { should match 'plymouth.enable=0' }
      its(:content) { should_not match 'xen_blkfront.sda_is_xvda=1' }

      it('should be of mode 600 (stig: V-38583)') { should be_mode(0600) }
      it('should be owned by root (stig: V-38579)') { should be_owned_by('root') }
      it('should be grouped into root (stig: V-38581)') do
        expect(subject.group).to eq('root')
      end
      it('audits processes that start prior to auditd (CIS-8.1.3)') do
        expect(subject.content).to match ' audit=1'
      end
    end
  end

  context 'modified by base_file_permissions' do
    describe 'disallow unsafe setuid binaries' do
      subject { command('find / -xdev -perm /ug=s -type f').stdout.split }

      it { should match_array(%w(/usr/bin/su /usr/bin/sudo)) }
    end

    describe 'disallow root login' do
      subject { file('/etc/ssh/sshd_config') }

      its(:content) { should match /^PermitRootLogin no$/ }
    end
  end

  context 'installed by system-network on all IaaSes', { exclude_on_warden: true } do
    describe file('/etc/hostname') do
      it { should be_file }
      its (:content) { should eq('bosh-stemcell') }
    end
  end

  context 'installed by bosh_aws_agent_settings', {
    exclude_on_openstack: true,
    exclude_on_vcloud: true,
    exclude_on_vsphere: true,
    exclude_on_warden: true,
    exclude_on_azure: true,
  } do
    describe file('/var/vcap/bosh/agent.json') do
      it { should be_valid_json_file }
      its(:content) { should match('"Type": "HTTP"') }
    end
  end

  context 'installed by bosh_google_agent_settings', {
    exclude_on_aws: true,
    exclude_on_openstack: true,
    exclude_on_vcloud: true,
    exclude_on_vsphere: true,
    exclude_on_warden: true,
    exclude_on_azure: true,
  } do
    describe file('/var/vcap/bosh/agent.json') do
      it { should be_valid_json_file }
      its(:content) { should match '"Type": "InstanceMetadata"' }
    end
  end

  context 'installed by bosh_vsphere_agent_settings', {
    exclude_on_aws: true,
    exclude_on_vcloud: true,
    exclude_on_openstack: true,
    exclude_on_warden: true,
    exclude_on_azure: true,
   } do
    describe file('/var/vcap/bosh/agent.json') do
      it { should be_valid_json_file }
      its(:content) { should match('"Type": "CDROM"') }
    end
  end

  context 'installed by bosh_azure_agent_settings', {
    exclude_on_aws: true,
    exclude_on_vcloud: true,
    exclude_on_vsphere: true,
    exclude_on_warden: true,
    exclude_on_openstack: true,
  } do
    describe file('/var/vcap/bosh/agent.json') do
      it { should be_valid_json_file }
      its(:content) { should match('"Type": "File"') }
      its(:content) { should match('"MetaDataPath": ""') }
      its(:content) { should match('"UserDataPath": "/var/lib/waagent/CustomData"') }
      its(:content) { should match('"SettingsPath": "/var/lib/waagent/CustomData"') }
      its(:content) { should match('"UseServerName": true') }
      its(:content) { should match('"UseRegistry": true') }
    end
  end

  context 'installed by bosh_softlayer_agent_settings', {
      exclude_on_aws: true,
      exclude_on_google: true,
      exclude_on_vcloud: true,
      exclude_on_vsphere: true,
      exclude_on_warden: true,
      exclude_on_azure: true,
      exclude_on_openstack: true,
  } do
    describe file('/var/vcap/bosh/agent.json') do
      it { should be_valid_json_file }
      its(:content) { should match('"Type": "File"') }
      its(:content) { should match('"SettingsPath": "/var/vcap/bosh/user_data.json"') }
      its(:content) { should match('"UseRegistry": true') }
    end
  end

  context 'installed by bosh_openstack_agent_settings', {
    exclude_on_aws: true,
    exclude_on_google: true,
    exclude_on_vcloud: true,
    exclude_on_vsphere: true,
    exclude_on_warden: true,
    exclude_on_azure: true,
    exclude_on_softlayer: true,
  } do
    describe file('/var/vcap/bosh/agent.json') do
      it { should be_valid_json_file }
      its(:content) { should match('"CreatePartitionIfNoEphemeralDisk": true') }
      its(:content) { should match('"Type": "ConfigDrive"') }
      its(:content) { should match('"Type": "HTTP"') }
    end
  end

  context 'systemd services' do
    describe 'logrotate' do
      describe 'should rotate every 15 minutes' do
        describe file('/etc/systemd/system/logrotate.timer') do
          it 'lists the schedule precisely' do
            expect(subject.content).to match(/^OnCalendar=\*:0\/15$/)
          end
        end
      end
    end
  end
end
