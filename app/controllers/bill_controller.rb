class BillController < ApplicationController
  include ActionView::Helpers::NumberHelper

  helper :roll_call
	before_filter :page_view, :only => [:show, :text]
  before_filter :get_params, :only => [:index, :all, :popular, :pending, :hot, :most_commentary, :readthebill]
  #before_filter :bill_profile_shared, :only => [:show, :comments, :money, :votes, :actions, :amendments, :text, :actions_votes, :news_blogs, :videos, :news, :blogs, :news_blogs, :topnews, :topblogs, :letters]
  before_filter :bill_profile_shared, :only => [:show, :comments, :money, :votes, :actions, :amendments, :text, :actions_votes, :videos, :topnews, :topblogs, :letters]
  before_filter :aavtabs, :only => [:actions, :amendments, :votes, :actions_votes]
  before_filter :get_range, :only => [:hot]
  skip_before_filter :store_location, :only => [:bill_vote, :status_text, :user_stats_ajax, :atom, :atom_blogs, :atom_news, :atom_top20, :atom_top_commentary, :atom_topblogs, :atom_topnews]

  TITLE_MAX_LENGTH = 150

  def roll_calls
    @roll_calls = RollCall.find_all_by_bill_id(params[:id])
    render :partial => 'roll_call/roll_calls_summary', :locals => { :rolls => @rolls }
  end

  def send_sponsor
    params.delete(:commit)
    bill = Bill.find(params[:id])
    people = [bill.sponsor] + bill.co_sponsors
    sponsors, no_email = people.partition(&:email)
    sponsors_email = sponsors.map{|s| s.email }
    
    Emailer::deliver_send_sponsors(sponsors_email, 'visitor@opencongress.org',
      params[:subject], params[:msg]) unless sponsors.empty?

    flash[:notice] = email_sent(sponsors, no_email)

    respond_to do |wants|
      wants.html do
        # Handle users with javascript disabled
        redirect_to :action => :show, :id => bill.ident
      end
      wants.js {}
    end
  end
  
  def index
    if params[:sort]
      case params[:sort]
      when 'popular'
        redirect_to :action => :popular
      when 'pending'
        redirect_to :action => :pending
      else
        redirect_to :action => :all        
      end
    else
      redirect_to :action => :all
    end    
  end
  
  def all
    # disabled caching for 
    #expires_in 20.minutes, :public => true
    @congress = params[:congress] ? params[:congress] : Settings.default_congress
    
    # the following is temporary until a better way is figured out!
    unless read_fragment("bill_#{@types}_index_#{@congress}")
      @bills = {}
      @bill_counts = {}
      @types_from_params.each do |bill_type|
        @bills[bill_type] = Bill.find_all_by_bill_type_and_session(bill_type, @congress, :order => 'lastaction DESC', :limit => 5)
        @bill_counts[bill_type] = Bill.count(:conditions => ['bill_type = ? AND session = ?', bill_type, @congress])
      end
    end
    
    @page_title = "#{@types.capitalize} Bills: #{@congress}th Congress"
    @title_desc = SiteText.find_title_desc('bill_all')
    @sort = 'all'

    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def popular
    @days = days_from_params(params[:days])
    @congress = params[:congress].blank? ? Settings.default_congress : params[:congress]
    if @congress != Settings.default_congress
      @bills = Bill.find(:all, :select => "bills.*, bills.page_views_count AS view_count", 
                         :conditions => ["session = ?", params[:congress]], 
                         :order => 'page_views_count DESC', :limit => 100)
    else
      unless read_fragment("bill_meta_popular_#{@days}")
        @bills = ObjectAggregate.popular('Bill', @days, 100)
      end
    end
    
    @atom = {'link' => url_for(:only_path => false, :controller => 'bill/atom/most', :action => 'viewed'), 'title' => "Top 20 Most Viewed Bills"}
    @page_title = 'Most Frequently Viewed Bills'
    @sort = 'popular'
    @title_desc = SiteText.find_title_desc('bill_popular')
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def pending
    @bills = Bill.find(:all, :include => [:bill_titles, :actions], 
                        :conditions => ["actions.datetime > ? AND bills.session = ? AND bills.bill_type IN (?)", 3.months.ago, Settings.default_congress, @types_from_params], 
                        :order => "actions.date DESC", :limit => 30)
                        
    @page_title = 'Pending Bills in Congress'
    @sort = 'pending'
    @title_desc = SiteText.find_title_desc('bill_pending')
    @exclude_introduced = (params[:exclude_introduced] == 'true') ? true : false
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def major
    @page_title = "Hot Bills"
    @sort = 'major'
    @title_desc = SiteText.find_title_desc('bill_hot')
    @types = 'all'
    @atom = {'link' => "/bill/major.rss", 'title' => "Major Bills"}
    @congress = params[:congress].blank? ? Settings.default_congress : params[:congress]
    @hot_bill_categories = PvsCategory.includes(:hot_bills).where(["bills.session = ?", @congress]).order("pvs_categories.name")
    
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
      format.rss {
        @hot_bills = Bill.find(:all, :conditions => ["session = ? AND hot_bill_category_id IS NOT NULL", @congress], 
                           :order => 'introduced DESC')
        render :action => 'major.rxml'
      }
    end
  end
  
  def hot
    @page_title = "Hot Bills on OpenCongress"
    @sort = 'hot'
    @bill = Bill.find_by_ident(params[:bill]) if params[:bill]
    @p_title_class = "bills"
    @p_title = "Bills"
    order = params[:order] ||= "desc" 
    if order == "asc"
      @p_subtitle = "Least "
    else
      @p_subtitle = "Most "
    end
    sort = params[:sort] ||= "vote_count_1"
    case sort
      when "vote_count_1"
        @p_subtitle << "Votes"
      when "current_support_pb"
        @p_subtitle << "Support"
      when "support_count_1"
        @p_subtitle << "Opposition"
      when "bookmark_count_1"
        @p_subtitle << "Users Tracking"
      when "total_comments"
        @p_subtitle << "Comments"
    end
    page = params[:page] ||= 1

    @cache_key = "br-bill-#{page}-#{sort}-#{order}-#{logged_in? ? current_user.login : nil}-#{@range}-#{params[:q].blank? ? nil : Digest::SHA1.hexdigest(params[:q])}"
    unless read_fragment(@cache_key)
      unless params[:q].blank?
        @r_count = Bill.count_all_by_most_user_votes_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Bill.find_all_by_most_user_votes_for_range(@range, :search => prepare_tsearch_query(params[:q]), :order => sort + " " + order, :total_entries => @r_count).paginate(:per_page => 20, :page => page)        
      else
        @r_count = Bill.count_all_by_most_user_votes_for_range(@range, :order => sort + " " + order, :per_page => 20, :page => page)
        @results = Bill.find_all_by_most_user_votes_for_range(@range, :order => sort + " " + order, :total_entries => @r_count).paginate(:page => page, :per_page => 20) 
      end
    end

    respond_to do |format|
      format.html
      format.xml {
        render :xml => @results.to_xml(:methods => [:title_full_common, :status, :ident], 
                                       :except => [:rolls, :hot_bill_category_id, :summary, 
                                                   :current_support_pb, :support_count_1, :rolls, :hot_bill_category_id, 
                                                   :support_count_2, :vote_count_2]) 
      }

    end
  end
 
  def hot_bill_vote
     @bill = Bill.find_by_ident(params[:bill])
       @bv = current_user.bill_votes.find_by_bill_id(@bill.id)
       unless @bv
         @bv = current_user.bill_votes.create({:bill_id => @bill.id, :user_id  => current_user.id, :support => (params[:id] == "1" ? 1 : 0) }) unless @bv
         update = {(params[:id] == "1" ? 'oppose' : 'support') => '+'}
       else
         if params[:id] == "1"
            if @bv.support == true
               @bv.destroy
               update = {'oppose' => '-'}
            else
               @bv.support = true
               @bv.save
               update = {'oppose' => '+', 'support' => '-'}
            end
         else
            if @bv.support == false
               @bv.destroy
               update = {'support' => '-'}
            else
               @bv.support = false
               @bv.save
               update = {'support' => '+', 'oppose' => '-'}
            end
         end
       end                                         
       render :update do |page|
         page.replace_html 'vote_results_' + @bill.id.to_s, :partial => "/bill/bill_votes"
           
           update.each_pair do |view, op|
             page << "$('#{view}_#{@bill.id.to_s}').update(parseInt($('#{view}_#{@bill.id.to_s}').innerHTML)#{op}1)"
             page.visual_effect :pulsate, "#{view}_#{@bill.id.to_s}"
           end
       end
   end   

  def list_bill_type
    congress = params[:congress] ? params[:congress] : Settings.default_congress
    @page = params[:page]
    @page = "1" unless @page
    @bill_type = params[:bill_type]

    @bills = Bill.where(["bills.bill_type=? AND bills.session=?", @bill_type, congress]).includes(:bill_titles).order('number').paginate(:page => @page)

    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def most_commentary
    @days = days_from_params(params[:days])
    @congress = params[:congress].blank? ? Settings.default_congress : params[:congress]
    
    if params[:type] == 'news'
      @sort = @commentary_type = 'news'
      @page_title = "Bills Most Written About In The News : #{@congress.to_i.ordinalize} Congress"
      @atom = {'link' => "/bill/atom/most/news", 'title' => @page_title}      
    else
      @sort = @commentary_type = 'blog'
      @page_title = "Bills Most Written About On Blogs : #{@congress.to_i.ordinalize} Congress"
      @atom = {'link' => "/bill/atom/most/blog", 'title' => @page_title}
    end
    
    if @congress != Settings.default_congress
      order = (@sort == 'news') ? 'news_article_count' : 'blog_article_count'
      @bills = Bill.find(:all, :select => "bills.*, bills.#{order} AS article_count", 
                         :conditions => ["session = ? AND #{order} IS NOT NULL", params[:congress]], 
                         :order => "#{order} DESC", :limit => 100)
    else
      unless read_fragment("bill_meta_most_#{@commentary_type}_#{@days}")
        @bills = Bill.find_by_most_commentary(@commentary_type, 20, @days, Settings.default_congress, @types_from_params)
      end
    end
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def upcoming
    @upcoming_bill = UpcomingBill.find(params[:id])
    @page_title = @upcoming_bill.title
    @comments = @user_object = @upcoming_bill
    respond_to do |format|
      format.html {}
      format.js { render :action => 'update'}
    end
  end

  def readthebill
    @show_resolutions = (params[:show_resolutions].blank? || params[:show_resolutions] == 'false') ? false : true
    
    @title_class = 'sort'

    case params[:sort]
    when 'rushed'
      @page_title = "Read the Bill - Bills Rushed to Vote"
      @bills = Bill.find_rushed_bills(Settings.default_congress, 72.hours.to_i, @show_resolutions).paginate :page => params[:page]
      @atom = {'link' => "/bill/readthebill.rss?show_resolutions=#{@show_resolutions}", 'title' => @page_title}
      @title_desc = SiteText.find_title_desc('bills_rushed')
      @sort = 'rushed'
    when 'rtb_all'
      @page_title = "Read the Bill - All Bills With Vote on Passage"
      @bills = Bill.find_rushed_bills(Settings.default_congress, 2.years.to_i, @show_resolutions).paginate :page => params[:page]
      @atom = {'link' => "/bill/readthebill.rss?sort=rtb_all&show_resolutions=#{@show_resolutions}", 'title' => @page_title} 
      @title_desc = SiteText.find_title_desc('bills_rushed_all')
      @sort = 'rtb_all'
    else
      @page_title = "Read the Bill - GPO Text Available to Consideration"
      @bills = Bill.find_gpo_consideration_rushed_bills(Settings.default_congress, 2.years.to_i, @show_resolutions).paginate :page => params[:page]
      @atom = {'link' => "/bill/readthebill.rss?sort=gpo&show_resolutions=#{@show_resolutions}", 'title' => @page_title} 
      @title_desc = SiteText.find_title_desc('bills_rushed_gpo')
      @sort = 'gpo'      
    end
    
    respond_to do |format|
      format.html
      format.rss { render :action => "readthebill.rxml" }
      format.js { render :action => 'update'}
    end
  end

  def atom
    session, bill_type, number = Bill.ident params[:id]
    @bill = Bill.find_by_session_and_bill_type_and_number session, bill_type, number, :include => :actions
    @posts = []
    expires_in 60.minutes, :public => true

    render :layout => false
  end

  def atom_news
    @bill = Bill.find_by_ident(params[:id])
    expires_in 60.minutes, :public => true
    @commentaries = @bill.news
    @commentary_type = 'news'

    render :action => 'commentary_atom', :layout => false
  end

  def atom_blogs
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.blogs
    @commentary_type = 'blog'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end

  def atom_topnews
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.news.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5)
    @commentary_type = 'topnews'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end

  def atom_topblogs
    @bill = Bill.find_by_ident(params[:id])
    @commentaries = @bill.blogs.find(:all, :conditions => "commentaries.average_rating > 5", :limit => 5)
    @commentary_type = 'topblog'
    expires_in 60.minutes, :public => true

    render :action => 'commentary_atom', :layout => false
  end

  def atom_top20
    @bills = Bill.top20_viewed
    @date_method = :entered_top_viewed
    @feed_title = "Top 20 Most Viewed Bills"
    @most_type = "viewed"
    expires_in 60.minutes, :public => true
    
    render :action => 'top20_atom', :layout => false
  end

  def atom_top_commentary
    if params[:type] == 'news'
      @most_type = commentary_type = 'news'
      @feed_title = "Top 20 Bills Most Written About In The News"
    else
      @most_type = commentary_type = 'blog'
      @feed_title = "Top 20 Bills Most Written About Blogs"
    end
    
    @date_method = :"entered_top_#{commentary_type}"
  
    @bills = Bill.top20_commentary(commentary_type)
    expires_in 60.minutes, :public => true

    render :action => 'top20_atom', :layout => false
  end

  # this action is to show a non-cached version of 'show'
  def show_f
    show
  end

  def comments
    respond_to do |format|
      format.html {
        comment_redirect(params[:goto_comment]) and return if params[:goto_comment]
      }
    end
  end

  def show
    #expires_in 20.minutes, :public => true
    respond_to do |format|
      format.html {
        comment_redirect(params[:goto_comment]) and return if params[:goto_comment]
        
        @include_vids_styles = true
        
        @tracking_suggestions = @bill.tracking_suggestions
        @supporting_suggestions = @bill.support_suggestions
        @opposing_suggestions = @bill.oppose_suggestions
        
        @latest_letters = @bill.contact_congress_letters.where("contact_congress_letters.is_public='t'").order("contact_congress_letters.created_at DESC").limit(3)
 
        # create roll call variable to include chart JS
        @roll_call = @bill.roll_calls.empty? ? nil : @bill.roll_calls.first
     }
      format.xml {
        render :xml => @bill.to_xml(:exclude => [:fti_titles], :include => [:bill_titles,:last_action,:sponsor,:co_sponsors,:actions,:roll_calls])
      }
    end
  end

  def user_stats_ajax
    @bill = Bill.find_by_id(params[:id])
    @tracking_suggestions = @bill.tracking_suggestions
    @supporting_suggestions = @bill.support_suggestions
    @opposing_suggestions = @bill.oppose_suggestions
    render :action => 'user_stats_ajax', :layout => false 
  end
  
  def letters
    @topic = nil
    @meta_description = "Letters to Congress regarding #{@bill.title_full_common} on OpenCongress.org"

    @page_title = "Letters to Congress: #{@bill.typenumber}"

    @letters = @bill.contact_congress_letters.includes(:formageddon_threads).where("formageddon_threads.privacy='PUBLIC'").order("contact_congress_letters.created_at DESC").paginate(:page => params[:page], :per_page => 10)
  end
  
  def text
    @topic = nil
    @meta_description = "Full bill text of #{@bill.title_full_common} on OpenCongress.org"

    # bill text code
    # build the list of versions
    @versions = @bill.bill_text_versions.find(:all, :conditions => "bill_text_versions.previous_version IS NULL")
    if @versions.empty?
      @bill_text = "We're sorry but OpenCongress does not have the full bill text at this time.  Try at <a href='http://thomas.loc.gov/cgi-bin/query/z?c#{@bill.session}:#{@bill.typenumber}:'>THOMAS</a>."
      @commented_nodes = []
      return
    end

    @version = @versions.first unless (params[:version].blank? or @versions.first.version != params[:version])

    v = @bill.bill_text_versions.find(:first, :conditions => ["bill_text_versions.previous_version=?", @versions.first.version])
    until v.nil?
      @versions << v
      @version = v unless (params[:version].blank? or v.version != params[:version])
      v = @bill.bill_text_versions.find(:first, :conditions => ["bill_text_versions.previous_version=?", v.version])
    end
    @version = @versions.last if @version.nil?

    @page_title = "Text of #{@bill.typenumber} as #{@version.pretty_version}"

    @nid = params[:nid].blank? ? nil : params[:nid]  
    @commented_nodes = @version.bill_text_nodes.find(:all, :include => :comments)   
    @top_nodes = @version.top_comment_nodes
    

    begin
      # open html from file
      path = "#{Settings.oc_billtext_path}/#{@bill.session}/#{@bill.bill_type}#{@bill.number}#{@version.version}.gen.html-oc"
      
      @bill_text = File.open(path).read
    rescue 
      @bill_text = "We're sorry but OpenCongress does not have the full bill text at this time.  Try at <a href='http://thomas.loc.gov/cgi-bin/query/z?c#{@bill.session}:#{@bill.typenumber}:'>THOMAS</a>."
    end
  end

  def print_text
    @bill = Bill.find_by_ident(params[:id])
    @bill_text = ""
    version = @bill.bill_text_versions.find(:first, :conditions => ["bill_text_versions.version=?", params[:version]])
    if version
      path = "#{Settings.oc_billtext_path}/#{@bill.session}/#{@bill.bill_type}#{@bill.number}#{version.version}.gen.html-oc"
      @bill_text = File.open(path).read
    end
    
    render :layout => false
  end

  def actions_votes
    respond_to do |format|
      format.html {
        unless @bill.roll_calls.empty?
          @roll_call = @bill.roll_calls[0]
          @aye_chart = ofc2(210,120, "roll_call/partyvote_piechart_data/#{@roll_call.id}?breakdown_type=#{CGI.escape("+")}&disclaimer_off=true&radius=40")
          @nay_chart = ofc2(210,120, "roll_call/partyvote_piechart_data/#{@roll_call.id}?breakdown_type=-&disclaimer_off=true&radius=40")
          @abstain_chart = ofc2(210,120, "roll_call/partyvote_piechart_data/#{@roll_call.id}?breakdown_type=0&disclaimer_off=true&radius=40")
        end
      }
      format.xml {
        render :xml => @bill.to_xml(:exclude => [:fti_titles], :include => [:bill_titles,:last_action,:sponsor,:co_sponsors,:actions,:roll_calls])
      }
    end
  end

  def amendments
    @amendments = @bill.amendments.paginate(:all, :page => @page, :per_page => 10, :order => ["retreived_date DESC"])
  end

  def actions
    @actions = @bill.actions.paginate(:all, :page => @page, :per_page => 10, :order => ["datetime::date DESC, id DESC"])
  end 
  
  def votes
    @roll_calls = @bill.roll_calls.paginate(:all, :page => @page, :per_page => 8, :order => ["date DESC"])
  end

  def comms
    @bill = Bill.find_by_ident(params[:ident])
    @comms = @bill.comments.paginate(:all, :order => ["created_at DESC"])
  end
  
  def wiki
      require 'hpricot'
      require 'mediacloth'
      require 'open-uri'
      wiki_url = "http://#{WIKI_HOST}/w/api.php?action=query&prop=revisions&titles=Economic_Stimulus_Bill_of_2008&rvprop=timestamp|content&format=xml"
      session, bill_type, number = Bill.ident params[:id]
      if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => [ :bill_titles ]})
         #unwise = %w({ } | \ ^ [ ] `)
         badchar = '|'
         escaped_uri = URI.escape(wiki_url)
         doc = Hpricot.XML(open(escaped_uri))
         logger.info doc.to_yaml
         content = (doc/:api/:query/:pages).first.inner_html
         logger.info content
         @wiki_content = MediaCloth::wiki_to_html(content)
      end
  end

  def status_text
    @bill = Bill.find_by_ident(params[:id])  
    
    render :layout => false
  end
  
  def news_blogs
    flash[:notice] = "News and blog archives have been temporarily disabled."
    redirect_to :action => 'show', :id => params[:id]
    return
    
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    unless read_fragment("#{@bill.fragment_cache_key}_news_blogs_#{@sort}")
      if @sort == 'toprated'
        @blogs = @bill.blogs.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC', :limit => 10)               
        @news = @bill.news.find(:all, :order => 'commentaries.average_rating IS NOT NULL DESC', :limit => 10)                                                                                  
      elsif @sort == 'oldest'
        @news = @bill.news.find(:all, :order => 'commentaries.date ASC', :limit => 10)
        @blogs = @bill.blogs.find(:all, :order => 'commentaries.date ASC', :limit => 10)
      else
        @news = @bill.news.find(:all, :limit => 10)
        @blogs = @bill.blogs.find(:all, :limit => 10)
      end
    end
  end

  def blogs
    flash[:notice] = "News and blog archives have been temporarily disabled."
    redirect_to :action => 'show', :id => params[:id]
    return
    
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end
    
    unless read_fragment("#{@bill.fragment_cache_key}_blogs_#{@sort}_page_#{@page}")
      if @sort == 'toprated'
        @blogs = @bill.blogs.paginate(:order => 'commentaries.average_rating IS NOT NULL DESC', :page => @page)
      elsif @sort == 'oldest'
        @blogs = @bill.blogs.paginate(:order => 'commentaries.date ASC', :page => @page)
      else
        @blogs = @bill.blogs.paginate :page => params[:page]
      end
    end
    
    @page_title = (@sort == 'toprated') ? "Highest Rated " : ""
    @page_title += "Blog Articles for #{@bill.typenumber}"
    
    if @sort == 'toprated'
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_topblogs'), 'title' => "#{@bill.typenumber} highest rated blog articles"}
    else
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom_blogs'), 'title' => "#{@bill.typenumber} blog articles"}
    end
  end

  def topblogs
    redirect_to :controller => 'bill', :action => 'blogs', :id => @bill.ident, :sort => 'toprated'
  end

  def money
    session, bill_type, number = Bill.ident(params[:id])
    if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => [ :bill_titles ]})
      respond_to do |format|
        format.html
      end
    else
      flash[:error] = "Invalid bill URL."
      redirect_to :action => 'all'
    end
  end

  def news
    flash[:notice] = "News and blog archives have been temporarily disabled."
    redirect_to :action => 'show', :id => params[:id]
    return
    
    if params[:sort] == 'toprated'
      @sort = 'toprated'
    elsif params[:sort] == 'oldest'
      @sort = 'oldest'
    else
      @sort = 'newest'
    end

    unless read_fragment("#{@bill.fragment_cache_key}_news_#{@sort}_page_#{@page}")
      if @sort == 'toprated'
        @news = @bill.news.paginate(:order => 'commentaries.average_rating IS NOT NULL DESC', :page => @page)
      elsif @sort == 'oldest'
        @news = @bill.news.paginate(:order => 'commentaries.date ASC', :page => @page)
      else
        @news = @bill.news.paginate :page => params[:page]
      end
    end

    @page_title = (@sort == 'toprated') ? "Highest Rated " : ""
    @page_title += "News Articles for #{@bill.typenumber}"
   
    if @sort == 'toprated'
      @atom = {'link' => url_for(:controller => 'bill', :id => @bill.ident, :action => 'atom_topnews'), 'title' => "#{@bill.typenumber} highest rated news articles"}
    else
      @atom = {'link' => url_for(:controller => 'bill', :id => @bill.ident, :action => 'atom_news'), 'title' => "#{@bill.typenumber} news articles"}
    end
  end

  def topnews
    redirect_to :controller => 'bill', :action => 'news', :id => @bill.ident, :sort => 'toprated'
  end

  def commentary_search
    @page = params[:page]
    @page = "1" unless @page

    @commentary_query = params[:q]
    query_stripped = prepare_tsearch_query(@commentary_query)
    @bill = Bill.find_by_ident(params[:id])

    if params[:commentary_type] == 'news'
      @commentary_type = 'news'
      @articles = @bill.news.paginate(:conditions => ["fti_names @@ to_tsquery('english', ?)", query_stripped], :page => @page)
    else
      @commentary_type = 'blogs'
      @articles = @bill.blogs.paginate(:conditions => ["fti_names @@ to_tsquery('english', ?)", query_stripped], :page => @page)
    end
    
    @page_title = "Search #{@commentary_type.capitalize} for bill #{@bill.typenumber}"
  end

  def videos
    @include_vids_styles = true
    @page_title = "Videos of #{@bill.typenumber}"
    @videos = @bill.videos.paginate :page => params[:page]
  end

  def bill_vote
    @bill = Bill.find_by_ident(params[:bill])
    if logged_in?
      @bv = current_user.bill_votes.find_by_bill_id(@bill.id)
      unless @bv
        @bv = current_user.bill_votes.create({:bill_id => @bill.id, :user_id  => current_user.id, :support => (params[:id] == "1" ? 1 : 0) }) unless @bv
      else
        if params[:id] == "1"
           if @bv.support == true
             @bv.destroy
           else
              @bv.support = true
              @bv.save
           end
        else
           if @bv.support == false
              @bv.destroy
           else
              @bv.support = false
              @bv.save
           end
        end
      end

      render :update do |page|
        page.replace_html 'vote_results_' + @bill.id.to_s, :partial => "bill_votes"
        page.replace_html 'users_result', user_bill_result(@bill)
        page.visual_effect :pulsate, 'users_result'
        #page.replace_html 'support_' + @bill.id.to_s, @bill.bill_votes.count(:all, :conditions => "support = 0")
        #page.replace_html 'oppose_' + @bill.id.to_s, @bill.bill_votes.count(:all, :conditions => "support = 1")
        #page.replace_html 'vote_message_' + @bill.id.to_s, :partial => "voted"
        #page.show 'vote_message_' + @bill.id.to_s
        #page.visual_effect :highlight, (@bv.support == 0 ? 'support_' : 'oppose_') + @bill.id.to_s if @bv
        #page.visual_effect :highlight, 'vote_message_' + @bill.id.to_s
      end
    else
      render :update do |page|
        page.replace_html 'vote_message_' + @bill.id.to_s, "You must <a href='/login'>login</a> to vote. No account? <a href='/register'>Register</a> now!"
        page.show 'vote_message_' + @bill.id.to_s
        page.visual_effect :highlight, 'vote_message_' + @bill.id.to_s
      end
    end
  end

private

  def get_params
    case params[:types]
      when "house"
        @types_from_params = Bill.in_house
        @types = "house"
      when "senate"
        @types_from_params = Bill.in_senate
        @types = "senate"
      else  
        @types_from_params = Bill.all_types_ordered
        @types = "all"
      end
      @carousel = [Bill.find_hot_bills('bills.page_views_count desc',{:limit => 12})]
  end

  def bill_profile_shared
    session, bill_type, number = Bill.ident params[:id]
    if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => [ :bill_titles ]})
      @page_title_prefix = "U.S. Congress"
      @page_title = @bill.typenumber
      @head_title = @bill.title_common
      if @bill.plain_language_summary.blank?
        @meta_description = "Official government data, breaking news and blog coverage, public comments and user community for #{@bill.title_full_common}"
      else
        @meta_description = @bill.plain_language_summary
      end
      @meta_keywords = "Congress, #{@bill.sponsor.popular_name unless @bill.sponsor.nil?}, " + @bill.subjects.find(:all, :order => 'bill_count DESC', :limit => 5).collect{|s| s.term}.join(", ")
      @sidebar_stats_object = @user_object = @comments = @topic = @bill
      @related_articles = @bill.related_articles
      @page = params[:page] || 1   

      if @bill.has_wiki_link?
        @wiki_url = @bill.wiki_url
      elsif logged_in?
        @wiki_create_url = "#{Settings.wiki_base_url}/Special:AddData/Bill?Bill[common_title]=#{CGI::escape(@bill.title_common[0..70])}&Bill[bill_type]=#{@bill.bill_type}&Bill[type_name]=#{@bill.type_name}&Bill[bill_number]=#{@bill.number}&Bill[congress]=#{Settings.default_congress}" #prolly should be rewritten as a post handled by a custom sfEditFormPreloadText call?
      end

      @tabs = [
        ["Overview",{:action => 'show', :id => @bill.ident}],
        ["Actions & Votes",{:action => 'actions_votes', :id => @bill.ident}]
      ]
      @tabs << ["Money Trail",{:action => 'money', :id => @bill.ident}] unless @bill.bill_interest_groups.empty?
      @tabs << ["News <span>(#{news_blog_count(@bill.news_article_count)})</span> & Blogs <span>(#{news_blog_count(@bill.blog_article_count)})</span>".html_safe,{:action => 'news_blogs', :id => @bill.ident}]
      @tabs << ["Videos".html_safe,{:action => 'videos', :id => @bill.ident}] unless @bill.videos.empty?
      @tabs << ["Comments <span>(#{number_with_delimiter(@comments.comments.size)})</span>".html_safe,{:action => 'comments', :id => @bill.ident}]
      
      @top_comments = @bill.comments.find(:all,:include => [:user], :order => "comments.plus_score_count - comments.minus_score_count DESC", :limit => 2)
      @bookmarking_image = "/images/fb-bill.jpg"
      @atom = {'link' => url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'atom'), 'title' => "#{@bill.typenumber} activity"}
    else
      flash[:error] = "Invalid bill URL."
      redirect_to :action => 'all'
    end    
  end
  
  def aavtabs
    @aavtabs = []
    @aavtabs <<  ["Amendments", {:controller => 'bill', :action => 'amendments', :id => @bill.ident}] unless @bill.amendments.empty?
    @aavtabs <<  ["Actions", {:controller => 'bill', :action => 'actions', :id => @bill.ident}] unless @bill.actions.empty?
    @aavtabs << ["Votes", {:controller => 'bill', :action => 'votes', :id => @bill.ident}] unless @bill.roll_calls.empty?
  end

  def page_view
    session, bill_type, number = Bill.ident params[:id]
    
    if @bill = Bill.find_by_session_and_bill_type_and_number(session, bill_type, number, { :include => :actions })
      key = "page_view_ip:Bill:#{@bill.id}:#{request.remote_ip}"
      unless read_fragment(key)
        begin
          @bill.increment!(:page_views_count)
        rescue
          raise if Rails.env == 'production'
        end
        @bill.page_view
        @bill.log_referrer(request.referer)
        write_fragment(key, "c", :expires_in => 1.hour)
      end
    end
  end

  def email_sent(sponsors, no_email)
    if sponsors && sponsors.size > 0
      res = "Email sent to #{sponsors.map(&:name).join(', ')}."
    else
      res = ''
    end
    if no_email
      if no_email.size > 1
        res += no_email.map(&:name).join(', ') + ' have no email address.'
      else
        res += no_email.map(&:name).join(', ') + ' does not have an email address.'
      end
    end
    res
  end

  def get_range
    params[:timeframe] ||= "30days"
    case params[:timeframe]
      when "1day"
        @range = 1.day.to_i
      when "5days"
        @range = 5.days.to_i
      when "30days"
        @range = 30.days.to_i
      when "1year"
        @range = 1.year.to_i
      when "AllTime"
        @range = 20.years.to_i
    end

    @perc_diff_in_days = Bill.percentage_difference_in_periods(@range).to_f

    @time_collection = [["1 Day","1day"],
                        ["5 Days","5days"],
                        ["30 Days","30days"],
                        ["1 Year","1year"],
                        ["All Time","AllTime"]]
  end
  
  def get_counts
    objects = @results.collect{|p| p.id}
    object_type = @results.first.class.to_s
    if object_type == "Person"
       @blog_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Person' AND commentariable_id in (?) AND created_at > ?", false, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @blog_count[x[0]] = x[1]}
       @news_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Person' AND commentariable_id in (?) AND created_at > ?", true, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @news_count[x[0]] = x[1]}
   elsif object_type == "Bill"
       @blog_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Bill' AND commentariable_id in (?) AND created_at > ?", false, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @blog_count[x[0]] = x[1]}
       @news_count = {}
       Commentary.count(:id, :conditions => ["is_news = ? AND commentariable_type = 'Bill' AND commentariable_id in (?) AND created_at > ?", true, objects, @range.seconds.ago], :group => "commentariable_id").each {|x| @news_count[x[0]] = x[1]}
   else   
      @blog_count = {}
      @news_count = {}
    end
  end
end
