class ArticlesController < ApplicationController      
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  skip_before_filter :store_location, :except => [:index, :list, :view]
  before_filter :get_blogroll

  public           
    def index
      return list
    end

    def show
      view
      return if params[:goto_comment]
      render :action => 'view'
    end
    
    def list
      if params[:tag] && @tag = CGI.unescape(params[:tag])
        @articles = Article.tagged_with(@tag, :any => true).paginate(:page => params[:page], :per_page => 15)
        @page_title = "Blog - Articles Tagged '#{@tag}'"
      elsif @month = params[:month]
        month, year = @month.split(/-/)

        unless month and year and (1..12).include?(month.to_i) and (2006..3000).include?(year.to_i)
          redirect_to :controller => 'blog'
          return
        end
        display_month = "#{Time.mktime(year, month).strftime("%B %Y")}"
        
        @page_title = "Blog - #{display_month}"

        @articles = Article.find_by_month_and_year(month, year).paginate(:page => params[:page], :per_page => 15)
      else      
        @articles = Article.paginate(:all, :conditions => 'published_flag = true', 
                                 :include => :user, :page => params[:page], :per_page => 15)
        
        @page_title = "Blog"
      end

      @atom = {'link' => 'http://feeds.feedburner.com/OpenCongressCongressGossipBlog', 'title' => "OpenCongress Blog"}
      @related_gossip = Gossip.latest(3)
      
      render :action => 'list'
    end

    def view
      render_404 and return unless params[:id]
      comment_redirect(params[:goto_comment]) and return if params[:goto_comment]
      
      begin
        @article = Article.find(params[:id], :include => :user)
      rescue
        flash[:error] = 'Blog article not found!'
        redirect_to :controller => 'blog'
        return
      end
      
      render_404 and return unless @article

      @meta_description = @article.excerpt.blank? ? @article.article : @article.excerpt
      @meta_keywords = @article.tags.collect{|t| t.name }.join(", ")
      @bookmarking_image = @article.frontpage_image_url
      
      @atom = {'link' => url_for(:only_path => false, :controller => 'articles', :action => 'atom'), 'title' => "OpenCongress Blog"}
      @related_gossip = Gossip.latest(3)
      @page_title_prefix = "Blog" 
      @page_title = "#{@article.title}" 
    end
    
    def atom
      @articles = Article.find(:all, :conditions => ['published_flag = true'], :limit => 10)
      expires_in 60.minutes, :public => true

      render :layout => false
    end

    def article_atom
      @article = Article.find(params[:id])
      expires_in 60.minutes, :public => true
     
      render :layout => false
    end
    
    def all_comments_atom
      @comments = Comment.find(:all, :conditions => "commentable_type = 'Article'", :limit => 20)
      expires_in 60.minutes, :public => true
      render :layout => false
    end
    
    def add_comment
      @article = Article.find(params[:id])
      @comment = Comment.new(params[:comment])
      @comment.parent_id = 0 
      @comment.commentable_type = 'Article'
      @comment.commentable_id = @article.id     
      if @comment.save
        expire_page :controller => 'blog'
        expire_page :controller => 'articles'
        expire_page :controller => 'articles', :action => 'view', :id => @article
        
        flash[:notice] = "Comment added"
        redirect_to article_url(@article)
      else
        flash[:error] = "There was an error adding your comment:<br><ul>"
        @comment.errors.each { |a,m| flash[:error] += "<li>#{m} </li>" }
        flash[:error] += "</ul>"
        render :action => 'view', :id => @article
      end
    end
    
    private
    
    def get_blogroll
      @blogroll = Article.find_by_title("***BLOGROLL***")
    end
end
