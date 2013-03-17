class Wiki < ActiveRecord::Base
  # This is not in app/models because it's not a real model.
  # But you could subclass this there if you wanted to use wiki tables in Rails.
  # eg. "class Page < Wiki" would use the wiki connection.
  require 'mediacloth'
  require 'hpricot'
  
  begin
    establish_connection :oc_wiki
  rescue ActiveRecord::AdapterNotSpecified
    logger.warn "WARNING: oc_wiki configuration is not specified in database.yml"
  end

  set_table_name 'text'

  # Monkey patch find_by_sql so that we check whether the server is up before we try to connect.
  # This avoids an issue where the AR socket blocks for a very long time.
  def self.find_by_sql(query)
    if (!connected? && !SocketTest.is_port_open?(configurations['oc_wiki']['host'], configurations['oc_wiki']['port'] || 3306))
      return nil
    end

    super(query)
  end

  def self.summary_text_for(article_name)
    begin
      a = find_by_sql(['select rev_id, rev_timestamp, t.old_text, p.page_title, p.page_namespace from revision r, page p, text t where r.rev_id = p.page_latest and t.old_id = r.rev_text_id and page_title = ?', article_name])

      return nil if (a.nil? || a.empty?)
    
      # for some reason, newlines were messing up mediacloth
      no_newlines = a[0].old_text.gsub(/\n/, '')
      no_newlines =~ /\{\{Article summary\|(.*?)\}\}/

      if $~[1].blank?
        return nil
      else
        # remove the <ref> tags before returning
        doc = Hpricot(MediaCloth.wiki_to_html($~[1]))                 
        doc.search("ref").remove
                  
        return doc.to_html
      end
    rescue
      return nil
    end
  end
  
  def self.wiki_link_for_bill(session, typenum)    
    begin
      link = find_by_sql(["SELECT smw_title AS wiki_title FROM smw_ids AS sids
                            INNER JOIN
                              (SELECT s_id FROM smw_rels2 INNER JOIN smw_ids AS p ON p_id=p.smw_id INNER JOIN smw_ids AS o ON o_id=o.smw_id 
                               WHERE p.smw_title='Congressnumber' AND o.smw_title=?)
                              AS num_q ON num_q.s_id=sids.smw_id
                            INNER JOIN
                              (SELECT s_id FROM smw_rels2 INNER JOIN smw_ids AS p ON p_id=p.smw_id INNER JOIN smw_ids AS o ON o_id=o.smw_id 
                               WHERE p.smw_title='Billnumber' AND o.smw_title=?)
                              AS bill_q ON bill_q.s_id=sids.smw_id", session, typenum])
      (link.nil? || link.empty?) ? nil : link.first.wiki_title
    rescue
      return nil
    end
  end
  
  def self.biography_text_for(member_name)
    begin
      a = find_by_sql(['select rev_id, rev_timestamp, t.old_text, p.page_title, p.page_namespace from revision r, page p, text t where r.rev_id = p.page_latest and t.old_id = r.rev_text_id and page_title = ?', member_name])

      #puts a[0].old_text
      
      return nil if (a.nil? || a.empty?)
    
      # for some reason, newlines were messing up mediacloth
      no_newlines = a[0].old_text.gsub(/\n/, '<br/>')   
      no_newlines =~ /==\s*?Bio(graphy)?\s*?==(.*?)==/
      
      if $~[2].blank?
        return nil
      else
        no_refs = $~[2].gsub(/<ref(.|\n)*?\/ref>/, '')
        no_links = no_refs.gsub(/\[(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/[^\s]*?)\]/ix, '')
        
        #puts "AFTER: #{no_links}"
        # remove the <ref> tags before returning
        doc = Hpricot(MediaCloth.wiki_to_html(no_links))                 
        doc.search("ref").remove

        html = doc.to_html
        
        html = html.gsub(/<a\s(.|\n)*?>/, '')
        html = html.gsub(/<\/a>/, '')
      end
    rescue
      return nil
    end
  rescue Exception => e
    puts e
    return nil
  end

end
