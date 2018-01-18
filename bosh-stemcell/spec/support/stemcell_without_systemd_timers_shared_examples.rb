shared_examples_for 'a stemcell without systemd timers' do
  context 'cron' do
    describe 'logrotate should rotate every 15 minutes' do
      describe file('/etc/cron.d/logrotate') do
        it 'lists the schedule precisely' do
          expect(subject.content).to match /\A0,15,30,45 \* \* \* \* root \/usr\/bin\/logrotate-cron\Z/
        end
      end
    end
  end
end
