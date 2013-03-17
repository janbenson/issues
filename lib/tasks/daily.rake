require 'o_c_logger'
namespace :update do
  desc "controls the running of parsing scripts that are intended to be run daily"

  task :rsync => :environment do
    begin
      system "sh #{Rails.root}/bin/daily/govtrack-rsync.sh #{Rails.root}/db/ "
    
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error rsyncing govtrack data!")
      else
        puts "rsyncing govtrack data!"
      end
      
    end
  end
  
  task :mailing_list => :environment do
    load '/home/jan/ruby/issues/bin/daily/civicrm_sync.rb'
  end

  task :bios => :environment do
    begin
      load (Rails.root) +  'bin/daily/daily_parse_bioguide.rb'
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error updating from bioguide!")
      else
        puts "Error updating from bioguide!"
      end
      throw e
    end
  end

  task :video => :environment do
    begin
      load 'bin/daily/daily_parse_video.rb'
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error getting video data!")
      else
        puts "Error getting video data!"
      end
      throw e
    end
  end

  task :people => :environment do
    begin
        Person.transaction {
        load '/home/jan/ruby/issues/bin/daily/daily_parse_people.rb'
        }
    end
    if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing people!")
    else
        puts "parsing people!"
     end
  end

  task :bills => :environment do
    begin
      load '/home/jan/ruby/issues/bin/daily/daily_parse_bills.rb'
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing bills!")
      else
        puts "Error parsing bills!"
      end
    end
  end

  task :bill_text => :environment do
    begin
      load '/home/jan/ruby/issues/bin/daily/daily_parse_bill_text.rb'
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing bill text!")
      else
        puts "Error parsing bill text!"
      end
    end
  end

  task :get_watchdog_ids => :environment do
    load 'bin/get_watchdog_ids.rb'
  end

  task :sunlightlabs => :environment do
    load 'bin/get_sunlightlabs_data.rb'
  end

  task :gpo_billtext_timestamps => :environment do
    begin
      load 'bin/daily/daily_gpo_billtext_timestamps.rb'
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing GPO timestamps!")
      else
        puts "Error parsing GPO timestamps!"
      end
      throw e
    end
  end

  task :amendments => :environment do
    begin
      Amendment.transaction {
        load 'bin/daily/daily_parse_amendments.rb'
      }
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing amendments!")
      else
        puts "Error parsing amendments!"
      end
      throw e
    end
  end

  task :committee_reports_parse => :environment do
    begin
      CommitteeReport.transaction {
        load 'home/jan/ruby/issues/bin/thomas_parse_committee_reports.rb'
      }
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing committee reports!")
      else
        puts "Error parsing committee reports!"
      end
    end
  end

  task :committee_reports => :environment do
    begin
      CommitteeReport.transaction {
        load '/home/jan/ruby/issues/bin/thomas_fetch_committee_reports.rb'
        load '/home/jan/ruby/issues/bin/thomas_parse_committee_reports.rb'
      }
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing committee reports!")
      else
        puts "Error parsing committee reports!"
      end
    end
  end

  task :committee_schedule => :environment do
    begin
      CommitteeMeeting.transaction {
        load 'bin/govtrack_parse_committee_schedules.rb'
      }
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing committee schedule!")
      else
        puts "Error parsing committee schedule!"
      end
      throw e
    end    
  end

  task :today_in_congress => :environment do
    begin
      CongressSession.transaction {
        load 'bin/parse_today_in_congress.rb'
      }
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing today in Congress!")
      else
        puts "Error parsing today in Congress!"
      end
      throw e
    end
  end

  task :roll_calls => :environment do
    begin
      load '/home/jan/ruby/issues/bin/daily/daily_parse_rolls.rb'
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing roll calls!")
      else
        puts "parsing roll calls!"
      end
    end
  end

  task :person_voting_similarities => :environment do
    begin
      load '/home/jan/ruby/issues/bin/daily/person_voting_similarities.rb'
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error compiling voting similarities!")
      else
        puts "Error compiling voting similarities!"
      end
    end
  end

  task :sponsored_bill_stats => :environment do
    begin
      load '/home/jan/ruby/issues/bin/daily/sponsored_bill_stats.rb'
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error compiling sponsored bill stats!")
      else
        puts "Error compiling sponsored bill stats!"
      end
      throw e
    end
  end
  
  task :realtime => :environment do
    begin
      load '/home/jan/ruby/issues/bin/daily/drumbone_realtime_api.rb'
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing Drumbone realtime API!")
      else
        puts "Error parsing Drumbone realtime API!"
      end
    end
  end
  
  task :project_vote_smart => :environment do
    begin
      load 'bin/daily/project_vote_smart.rb'
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error parsing PVS data!")
      else
        puts "Error parsing PVS data!"
      end
      throw e
    end
  end

  task :gossip => :environment do
    begin
      system "wget http://www.opencongress.org/news/?feed=atom -O /tmp/dev.atom"
      rss = SimpleRSS.new open("/tmp/dev.atom")
      Gossip.transaction {
        rss.entries.each do |e|
          g = Gossip.find_or_create_by_link(e[:link])
          attrs = g.attributes
          g.name = e[:author]
          g.email = "dev@opencongress.org"
          g.link = e[:link]
          g.tip = e[:content]
          g.title = e[:title]
          g.approved = true
          g.save unless g.attributes == attrs
        end
      }
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error running gossip!")
      else
        puts "Error running gossip!"
      end
      throw e
    end
  end

  task :expire_cached_bill_fragments => :environment do
    begin
      require File.dirname(__FILE__) + '/../../app/models/bill.rb'
      require File.dirname(__FILE__) + '/../../app/models/fragment_cache_sweeper.rb'

      Bill.expire_meta_govtrack_fragments

      # TO DO: only invalidate updated bills
      bills = Bill.find(:all, :conditions => ["session = ?", Settings.default_congress])
      bills.each do |b|
        b.send :expire_govtrack_fragments
      end
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error expiring cached bill fragments!")
      else
        puts "Error expiring cached bill fragments!"
      end
      throw e
    end
  end

  task :expire_cached_person_fragments => :environment do
    begin
      require File.dirname(__FILE__) + '/../../app/models/person.rb'
      require File.dirname(__FILE__) + '/../../app/models/fragment_cache_sweeper.rb'

      # TO DO: only invalidate updated people
      people = Person.all_sitting
      people.each do |p|
        p.send :expire_govtrack_fragments
      end
    rescue Exception => e
      if (['production', 'staging'].include?(Rails.env))
        Emailer.deliver_rake_error(e, "Error expiring cached person fragments!")
      else
        puts "Error expiring cached person fragments!"
      end
      throw e
    end
  end

  # CRP data tasks 
  task :crp_interest_groups => :environment do
    begin
      load 'bin/crp/parse_interest_groups.rb'
    rescue Exception => e
      #Emailer.deliver_rake_error(e, "Error compiling voting similarities!")
      throw e
    end
  end

  task :maplight_bill_positions => :environment do
    begin
      load 'bin/crp/maplight_bill_positions.rb'
    rescue Exception => e
      #Emailer.deliver_rake_error(e, "Error compiling voting similarities!")
      throw e
    end
  end
  
  task :partytime_fundraisers => :environment do
    begin
      load 'bin/crp/partytime_fundraisers.rb'
    rescue Exception => e
      #Emailer.deliver_rake_error(e, "Error compiling voting similarities!")
      throw e
    end
  end

  task :all => [:rsync, :people, :bills, :amendments, :roll_calls, :committee_reports, :committee_schedule, :person_voting_similarities, :sponsored_bill_stats, :expire_cached_bill_fragments, :expire_cached_person_fragments]
  task :finishup => [:mailing_list, :person_voting_similarities, :sponsored_bill_stats, :expire_cached_bill_fragments, :expire_cached_person_fragments]
  task :parse_all => [ :people, :bills, :amendments, :roll_calls, :committee_reports, :committee_schedule]
  task :govtrack => [ :rsync, :people, :bills, :amendments, :roll_calls, :expire_cached_bill_fragments, :expire_cached_person_fragments]
  task :committee_info => [:committee_reports, :committee_schedule]
  task :people_meta_data => [:person_voting_similarities, :sponsored_bill_stats, :expire_cached_person_fragments]
end
