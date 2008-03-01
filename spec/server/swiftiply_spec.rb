require File.dirname(__FILE__) + '/../spec_helper'

if SWIFTIPLY_PATH.empty?
  warn "Ignoring Server on Swiftiply specs, gem install swiftiply to run"
else
  describe Server, 'on Swiftiply' do
    before do
      @swiftiply = fork do
        exec "#{SWIFTIPLY_PATH} -c #{File.dirname(__FILE__)}/swiftiply.yml"
      end
      sleep 0.5
      start_server(Backends::SwiftiplyClient.new('0.0.0.0', 5555, nil)) do |env|
        body = env.inspect + env['rack.input'].read
        [200, { 'Content-Type' => 'text/html', 'Content-Length' => body.size.to_s }, body]
      end
    end
    
    it 'should GET from Net::HTTP' do
      Net::HTTP.get(URI.parse("http://0.0.0.0:3333/?cthis")).should include('cthis')
    end
  
    it 'should POST from Net::HTTP' do
      Net::HTTP.post_form(URI.parse("http://0.0.0.0:3333/"), :arg => 'pirate').body.should include('arg=pirate')
    end
  
    after do
      stop_server
      Process.kill(9, @swiftiply)
    end
  end
end