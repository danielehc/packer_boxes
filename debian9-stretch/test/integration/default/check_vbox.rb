describe service('vboxadd') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
end

describe file('/home/vagrant/VBoxGuestAdditions.iso') do
    it { should_not exist }
end
