#!/usr/bin/env ruby
require 'yaml'

class VpnPing
  def initialize
    @items = YAML.load_file('./item_list.yml')
    @avg_speeds = Hash.new
  end

  def execute_command(url)
    `ping -c 10 -q #{url}`
  end

  def packet_loss(command_result)
    # 0.0% packet loss
    command_result.scan(/\d+.\d+\%/).last
  end

  def speed_statistics(command_result)
    # min/avg/max/stddev
    command_result.scan(/\d*.\d*\/\d*.\d*\/\d*.\d*\/\d*.\d*/).first.split('/')
  end


  def ping
    @items.each do |name, url|
      command_result = execute_command(url)
      avg_speed = speed_statistics(command_result)[1].to_f
      packet_loss = packet_loss command_result
      puts name
      puts "丢包率为:       #{packet_loss}"
      puts "平均速度为:     #{avg_speed}ms"

      # 丢爆率大于 10%, 跳过
      @avg_speeds[name] = avg_speed unless packet_loss.scan(/\d+.\d+/).last.to_f > 10
    end

    @avg_speeds.values.sort!{ |a, b| a <=> b }
    if @avg_speeds.empty?
      puts '您的网络不太适合使用VPN'
    else
      puts "使用 #{@avg_speeds.first.first} 的网络"
    end
  end

end

p VpnPing.new.ping