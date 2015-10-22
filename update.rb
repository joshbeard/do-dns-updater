#!/usr/bin/env ruby
require 'droplet_kit'
require "net/http"
require "uri"
require 'optparse'

@options = {
  create: true,
  wan: 'http://checkip.dyndns.org:8245/',
  api_token: ENV['DO_API_TOKEN'] || nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on('-t', '--token API_TOKEN', 'Required: API Token. Can also set via environment variable DO_API_TOKEN') { |v| @options[:api_token] = v }
  opts.on('-d', '--domain DOMAIN', 'Required: Domain name e.g. example.com') { |v| @options[:domain] = v }
  opts.on('-r', '--record RECORD', 'Required: Record Name e.g. home') { |v| @options[:record] = v }
  opts.on('-c', '--[no-]create', "Optional: Create record if it doesn't exist. Default: #{@options[:create]}") { |v| @options[:create] = v }
  opts.on('-w', '--wan URL', "Optional: URL to check WAN IP. Default: #{@options[:wan]}") { |v| @options[:wan] = v }

end.parse!

def client
  DropletKit::Client.new(access_token: @options[:api_token]) || nil
end

def domain
  client.domain_records.all(for_domain: @options[:domain]) || nil
end

def record
  domain.each do |r|
    return r if (r['name'] == @options[:record] and r['type'] == 'A')
  end
  nil
end

def external_ip
  uri = URI.parse(@options[:wan])
  response = Net::HTTP.get(uri) || nil
  return response.match(/\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/).to_s.chomp if response
  nil
end

def current_ip
  record['data'].to_s.chomp || nil
end

def update
  puts "=> Updating record #{@options[:record]} for domain #{@options[:domain]}, id #{record['id']}"
  r = DropletKit::DomainRecord.new(name: @options[:record], data: external_ip)
  client.domain_records.update(r, for_domain: @options[:domain], id: record['id'])
end

def create
  puts "=> Creating A record #{@options[:record]} for domain #{@options[:domain]}"
  r = DropletKit::DomainRecord.new(name: @options[:record], data: external_ip, type: 'A')
  client.domain_records.create(r, for_domain: @options[:domain])
end

puts "-------------------------------------------------------"
puts "DigitalOcean DNS Updater"
puts Time.now
puts "Record: #{@options[:record]}.#{@options[:domain]}"
puts "Current WAN IP: " + external_ip

if record
  puts "Current Record: " + current_ip
  unless current_ip == external_ip
    update
  end
else
  create
end
puts "-------------------------------------------------------"
