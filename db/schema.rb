# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130310001853) do

  create_table "action_references", :force => true do |t|
    t.integer "action_id"
    t.string  "label"
    t.string  "ref"
  end

  create_table "actions", :force => true do |t|
    t.string   "action_type"
    t.integer  "date"
    t.datetime "datetime"
    t.string   "how"
    t.string   "where"
    t.string   "vote_type"
    t.string   "result"
    t.integer  "bill_id"
    t.integer  "amendment_id"
    t.string   "type"
    t.text     "text"
    t.integer  "roll_call_id"
    t.integer  "roll_call_number"
    t.datetime "created_at"
    t.integer  "govtrack_order"
  end

  add_index "actions", ["bill_id"], :name => "actions_bill_id_index"
  add_index "actions", ["roll_call_id"], :name => "index_actions_on_roll_call_id"

  create_table "amendments", :force => true do |t|
    t.string   "number"
    t.integer  "retreived_date"
    t.string   "status"
    t.integer  "status_date"
    t.datetime "status_datetime"
    t.integer  "offered_date"
    t.datetime "offered_datetime"
    t.integer  "bill_id"
    t.text     "purpose"
    t.text     "description"
    t.datetime "updated"
    t.integer  "key_vote_category_id"
  end

  add_index "amendments", ["bill_id", "number"], :name => "amendments_bill_id_index"

  create_table "api_hits", :force => true do |t|
    t.string   "action"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip",         :limit => 50
  end

  create_table "article_images", :force => true do |t|
    t.integer "article_id"
    t.string  "image"
  end

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.text     "article"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published_flag"
    t.boolean  "frontpage",           :default => false
    t.integer  "user_id"
    t.string   "render_type"
    t.string   "frontpage_image_url"
    t.text     "excerpt"
    t.tsvector "fti_names"
  end

  add_index "articles", ["created_at"], :name => "articles_created_at_index"
  add_index "articles", ["fti_names"], :name => "articles_fti_names_index"

  create_table "bad_commentaries", :id => false, :force => true do |t|
    t.text     "url"
    t.integer  "commentariable_id"
    t.string   "commentariable_type"
    t.datetime "date"
    t.integer  "id",                  :null => false
  end

  add_index "bad_commentaries", ["commentariable_id", "commentariable_type"], :name => "index_bad_commentaries_on_cid_and_ctype"
  add_index "bad_commentaries", ["url"], :name => "index_bad_commentaries_on_url"

  create_table "bill_battles", :force => true do |t|
    t.integer  "first_bill_id"
    t.integer  "second_bill_id"
    t.integer  "first_score"
    t.integer  "second_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.boolean  "active"
    t.datetime "run_date"
  end

  create_table "bill_fulltext", :id => false, :force => true do |t|
    t.integer  "bill_id"
    t.text     "fulltext"
    t.tsvector "fti_names"
  end

  add_index "bill_fulltext", ["bill_id"], :name => "bill_fulltext_bill_id_index"
  add_index "bill_fulltext", ["fti_names"], :name => "bill_fti_names_index"

  create_table "bill_interest_groups", :force => true do |t|
    t.integer "bill_id",               :null => false
    t.integer "crp_interest_group_id", :null => false
    t.string  "disposition"
  end

  create_table "bill_position_organizations", :force => true do |t|
    t.integer "bill_id",                  :null => false
    t.integer "maplight_organization_id", :null => false
    t.string  "name"
    t.string  "disposition"
    t.text    "citation"
  end

  add_index "bill_position_organizations", ["bill_id"], :name => "index_bill_position_organizations_on_bill_id"

  create_table "bill_referrers", :force => true do |t|
    t.integer  "bill_id"
    t.string   "url"
    t.datetime "created_at"
  end

  add_index "bill_referrers", ["bill_id"], :name => "index_bill_referrers_on_bill_id"
  add_index "bill_referrers", ["url"], :name => "index_bill_referrers_on_url"

  create_table "bill_stats", :id => false, :force => true do |t|
    t.integer  "bill_id",            :null => false
    t.datetime "entered_top_viewed"
    t.datetime "entered_top_news"
    t.datetime "entered_top_blog"
  end

  create_table "bill_subjects", :force => true do |t|
    t.integer "bill_id"
    t.integer "subject_id"
  end

  add_index "bill_subjects", ["bill_id"], :name => "index_bill_subjects_on_bill_id"
  add_index "bill_subjects", ["subject_id"], :name => "bill_subjects_subject_id_index"

  create_table "bill_text_nodes", :force => true do |t|
    t.integer "bill_text_version_id"
    t.string  "nid"
  end

  add_index "bill_text_nodes", ["bill_text_version_id"], :name => "index_bill_text_nodes_on_bill_text_version_id"
  add_index "bill_text_nodes", ["nid"], :name => "index_bill_text_nodes_on_nid"

  create_table "bill_text_versions", :force => true do |t|
    t.integer  "bill_id"
    t.string   "version"
    t.integer  "word_count",            :default => 0
    t.string   "previous_version"
    t.integer  "difference_size_chars", :default => 0
    t.integer  "percent_change",        :default => 0
    t.integer  "total_changes",         :default => 0
    t.datetime "file_timestamp"
  end

  add_index "bill_text_versions", ["bill_id"], :name => "index_bill_text_versions_on_bill_id"

  create_table "bill_titles", :force => true do |t|
    t.string   "title_type"
    t.string   "as"
    t.integer  "bill_id"
    t.text     "title"
    t.tsvector "fti_titles"
    t.boolean  "is_default", :default => false
  end

  add_index "bill_titles", ["bill_id"], :name => "bill_titles_bill_id_index"
  add_index "bill_titles", ["fti_titles"], :name => "bill_titles_fti_titles_index"
  add_index "bill_titles", ["title"], :name => "bill_titles_title_index"

  create_table "bill_votes", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "user_id"
    t.integer  "support",    :limit => 2, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bill_votes", ["bill_id"], :name => "index_bill_votes_on_bill_id"
  add_index "bill_votes", ["created_at"], :name => "index_bill_votes_on_created_at"
  add_index "bill_votes", ["user_id"], :name => "index_bill_votes_on_user_id"

  create_table "bills", :force => true do |t|
    t.integer  "session"
    t.string   "bill_type",              :limit => 2
    t.integer  "number"
    t.integer  "introduced"
    t.integer  "sponsor_id"
    t.integer  "lastaction"
    t.string   "rolls"
    t.integer  "last_vote_date"
    t.string   "last_vote_where"
    t.integer  "last_vote_roll"
    t.integer  "last_speech"
    t.string   "pl"
    t.integer  "topresident_date"
    t.date     "topresident_datetime"
    t.text     "summary"
    t.text     "plain_language_summary"
    t.integer  "hot_bill_category_id"
    t.datetime "updated"
    t.integer  "page_views_count"
    t.boolean  "is_frontpage_hot"
    t.integer  "news_article_count",                  :default => 0
    t.integer  "blog_article_count",                  :default => 0
    t.text     "caption"
    t.integer  "key_vote_category_id"
  end

  add_index "bills", ["hot_bill_category_id"], :name => "index_bills_on_hot_bill_category_id"
  add_index "bills", ["introduced"], :name => "index_bills_on_introduced"
  add_index "bills", ["number", "session", "bill_type"], :name => "bills_number_index"
  add_index "bills", ["sponsor_id"], :name => "bills_sponsor_id_index"

  create_table "bills_committees", :force => true do |t|
    t.integer "bill_id"
    t.integer "committee_id"
    t.string  "activity"
  end

  add_index "bills_committees", ["bill_id"], :name => "index_bills_committees_on_bill_id"
  add_index "bills_committees", ["committee_id"], :name => "index_bills_committees_on_committee_id"

  create_table "bills_cosponsors", :force => true do |t|
    t.integer "person_id"
    t.integer "bill_id"
    t.date    "date_added"
    t.date    "date_withdrawn"
  end

  add_index "bills_cosponsors", ["bill_id"], :name => "index_bills_cosponsors_on_bill_id"
  add_index "bills_cosponsors", ["person_id"], :name => "index_bills_cosponsors_on_person_id"

  create_table "bills_relations", :force => true do |t|
    t.string  "relation"
    t.integer "bill_id"
    t.integer "related_bill_id"
  end

  add_index "bills_relations", ["bill_id", "related_bill_id"], :name => "bills_relations_bill_id_index"

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at",                                      :null => false
    t.string   "bookmarkable_type", :limit => 15, :default => "", :null => false
    t.integer  "bookmarkable_id",                 :default => 0,  :null => false
    t.integer  "user_id",                         :default => 0,  :null => false
  end

  add_index "bookmarks", ["bookmarkable_id"], :name => "index_bookmarks_on_bookmarkable_id"
  add_index "bookmarks", ["bookmarkable_type"], :name => "index_bookmarks_on_bookmarkable_type"
  add_index "bookmarks", ["user_id"], :name => "index_bookmarks_on_user_id"

  create_table "comment_scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "score"
    t.datetime "created_at"
    t.string   "ip_address"
  end

  add_index "comment_scores", ["comment_id", "ip_address"], :name => "index_comment_scores_on_comment_id_and_ip_address"

  create_table "commentaries", :force => true do |t|
    t.string   "title",               :limit => nil
    t.text     "url"
    t.text     "excerpt"
    t.datetime "date"
    t.string   "source"
    t.string   "source_url"
    t.integer  "weight"
    t.string   "scraped_from"
    t.string   "status"
    t.string   "contains_term"
    t.tsvector "fti_names"
    t.datetime "created_at"
    t.boolean  "is_news"
    t.boolean  "is_ok",                              :default => false
    t.float    "average_rating"
    t.integer  "commentariable_id"
    t.string   "commentariable_type"
  end

  add_index "commentaries", ["commentariable_id", "commentariable_type", "is_ok", "is_news"], :name => "index_commentaries_on_commentariable_id_and_commentariable_type"
  add_index "commentaries", ["commentariable_type", "date", "is_ok", "is_news"], :name => "index_commentaries_on_commentariable_type_and_date_and_is_ok_an"
  add_index "commentaries", ["fti_names"], :name => "commentary_fti_names_index"
  add_index "commentaries", ["status"], :name => "index_commentaries_on_status"
  add_index "commentaries", ["url"], :name => "commentaries_url_index"

  create_table "commentary_ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentary_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "comment"
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.string   "homepage"
    t.datetime "created_at"
    t.integer  "parent_id"
    t.string   "title"
    t.datetime "updated_at"
    t.float    "average_rating",    :default => 5.0
    t.boolean  "censored",          :default => false
    t.boolean  "ok"
    t.integer  "rgt"
    t.integer  "lft"
    t.integer  "root_id"
    t.tsvector "fti_names"
    t.boolean  "flagged",           :default => false
    t.string   "ip_address"
    t.integer  "plus_score_count",  :default => 0,     :null => false
    t.integer  "minus_score_count", :default => 0,     :null => false
    t.boolean  "spam"
    t.string   "defensio_sig"
    t.float    "spaminess"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["created_at", "commentable_type"], :name => "index_comments_on_created_at_and_commentable_type"
  add_index "comments", ["fti_names"], :name => "comments_fti_names_index"
  add_index "comments", ["ok"], :name => "index_comments_on_ok"
  add_index "comments", ["parent_id"], :name => "index_comments_on_parent_id"
  add_index "comments", ["root_id"], :name => "index_comments_on_root_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "committee_meetings", :force => true do |t|
    t.text     "subject"
    t.datetime "meeting_at"
    t.integer  "committee_id"
    t.string   "where"
  end

  create_table "committee_meetings_bills", :force => true do |t|
    t.integer "committee_meeting_id"
    t.integer "bill_id"
  end

  create_table "committee_reports", :force => true do |t|
    t.string   "name"
    t.integer  "index"
    t.integer  "number"
    t.string   "kind"
    t.integer  "person_id"
    t.integer  "bill_id"
    t.integer  "committee_id"
    t.integer  "congress"
    t.text     "title"
    t.datetime "reported_at"
    t.datetime "created_at"
  end

  add_index "committee_reports", ["name"], :name => "committee_reports_name_index"

  create_table "committee_stats", :id => false, :force => true do |t|
    t.integer  "committee_id",       :null => false
    t.datetime "entered_top_viewed"
  end

  create_table "committees", :force => true do |t|
    t.string   "name"
    t.string   "subcommittee_name"
    t.tsvector "fti_names"
    t.boolean  "active",            :default => true
    t.string   "code"
    t.integer  "page_views_count"
  end

  add_index "committees", ["fti_names"], :name => "committees_fti_names_index"

  create_table "committees_people", :force => true do |t|
    t.integer "committee_id"
    t.integer "person_id"
    t.string  "role"
    t.integer "session"
  end

  create_table "comparison_data_points", :force => true do |t|
    t.integer  "comparison_id"
    t.integer  "comp_value"
    t.integer  "comp_indx"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comparisons", :force => true do |t|
    t.string   "type"
    t.integer  "congress"
    t.string   "chamber"
    t.integer  "average_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "congress_sessions", :force => true do |t|
    t.string  "chamber"
    t.date    "date"
    t.boolean "is_in_session"
  end

  add_index "congress_sessions", ["date"], :name => "index_congress_sessions_on_date"

  create_table "contact_congress_letters", :force => true do |t|
    t.integer  "user_id"
    t.string   "disposition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "receive_replies",  :default => true
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.boolean  "is_public",        :default => false
  end

  add_index "contact_congress_letters", ["contactable_id", "contactable_type"], :name => "contactable_index"

  create_table "contact_congress_letters_formageddon_threads", :id => false, :force => true do |t|
    t.integer "contact_congress_letter_id"
    t.integer "formageddon_thread_id"
  end

  add_index "contact_congress_letters_formageddon_threads", ["contact_congress_letter_id"], :name => "index_cclft_cclid"
  add_index "contact_congress_letters_formageddon_threads", ["formageddon_thread_id"], :name => "index_cclft_ftid"

  create_table "crp_contrib_individual_to_candidate", :id => false, :force => true do |t|
    t.string  "cycle",                   :null => false
    t.string  "fec_trans_id",            :null => false
    t.string  "fec_contrib_id"
    t.string  "name",                    :null => false
    t.string  "recipient_osid"
    t.string  "org"
    t.string  "parent_org"
    t.string  "crp_interest_group_osid"
    t.date    "contrib_date",            :null => false
    t.integer "amount"
    t.string  "street"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.string  "recip_code"
    t.string  "contrib_type"
    t.string  "pac_id"
    t.string  "other_pac_id"
    t.string  "gender"
    t.string  "fed_occ_emp"
    t.string  "microfilm"
    t.string  "occ_ef"
    t.string  "emp_ef"
    t.string  "source"
  end

  add_index "crp_contrib_individual_to_candidate", ["crp_interest_group_osid"], :name => "index_crp_contrib_individual_to_candidate_on_crp_interest_group"
  add_index "crp_contrib_individual_to_candidate", ["recipient_osid"], :name => "index_crp_contrib_individual_to_candidate_on_recipient_osid"

  create_table "crp_contrib_pac_to_candidate", :id => false, :force => true do |t|
    t.string  "cycle",                   :null => false
    t.string  "fec_trans_id",            :null => false
    t.string  "crp_pac_osid",            :null => false
    t.string  "recipient_osid"
    t.integer "amount",                  :null => false
    t.date    "contrib_date",            :null => false
    t.string  "crp_interest_group_osid"
    t.string  "contrib_type"
    t.string  "direct_or_indirect",      :null => false
    t.string  "fec_cand_id"
  end

  add_index "crp_contrib_pac_to_candidate", ["crp_interest_group_osid"], :name => "index_crp_contrib_pac_to_candidate_on_crp_interest_group_osid"
  add_index "crp_contrib_pac_to_candidate", ["recipient_osid"], :name => "index_crp_contrib_pac_to_candidate_on_recipient_osid"

  create_table "crp_contrib_pac_to_pac", :id => false, :force => true do |t|
    t.string "cycle",                                  :null => false
    t.string "fec_trans_id",                           :null => false
    t.string "filer_osid"
    t.string "donor_name"
    t.string "filer_name"
    t.string "donor_city"
    t.string "donor_state"
    t.string "donor_zip"
    t.string "fed_occ_emp"
    t.string "donor_crp_interest_group_osid"
    t.date   "contrib_date",                           :null => false
    t.float  "amount"
    t.string "recipient_osid"
    t.string "party"
    t.string "other_id"
    t.string "recipient_type"
    t.string "recipient_crp_interest_group_osid"
    t.string "amended"
    t.string "report_type"
    t.string "election_type"
    t.string "microfilm"
    t.string "contrib_type"
    t.string "donor_realcode_crp_interest_group_osid"
    t.string "realcode_source"
  end

  add_index "crp_contrib_pac_to_pac", ["filer_osid"], :name => "index_crp_contrib_pac_to_pac_on_filer_osid"
  add_index "crp_contrib_pac_to_pac", ["recipient_crp_interest_group_osid"], :name => "index_crp_contrib_pac_to_pac_on_recipient_crp_interest_group_os"

  create_table "crp_industries", :force => true do |t|
    t.string  "name",          :null => false
    t.integer "crp_sector_id"
  end

  create_table "crp_interest_groups", :force => true do |t|
    t.string  "osid",            :null => false
    t.string  "name"
    t.integer "crp_industry_id"
    t.string  "order"
  end

  add_index "crp_interest_groups", ["osid"], :name => "index_crp_interest_groups_on_osid"

  create_table "crp_pacs", :force => true do |t|
    t.string  "fec_id",                                       :null => false
    t.string  "osid",                                         :null => false
    t.string  "name",                                         :null => false
    t.integer "affiliate_pac_id"
    t.integer "parent_pac_id"
    t.string  "recipient_type"
    t.integer "recipient_person_id"
    t.string  "party"
    t.integer "crp_interest_group_id"
    t.string  "crp_interest_group_source"
    t.boolean "is_sensitive",              :default => false
    t.boolean "is_foreign",                :default => false
    t.boolean "is_active",                 :default => true
  end

  create_table "crp_sectors", :force => true do |t|
    t.string "name",         :null => false
    t.string "display_name"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "districts", :force => true do |t|
    t.integer  "district_number"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "center_lat",      :precision => 15, :scale => 10
    t.decimal  "center_lng",      :precision => 15, :scale => 10
  end

  create_table "facebook_templates", :force => true do |t|
    t.string "template_name", :null => false
    t.string "content_hash",  :null => false
    t.string "bundle_id"
  end

  add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true

  create_table "facebook_user_bills", :force => true do |t|
    t.integer  "facebook_user_id"
    t.integer  "bill_id"
    t.string   "tracking_type"
    t.text     "comment"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "facebook_users", :force => true do |t|
    t.integer  "facebook_uid"
    t.string   "facebook_session_key"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "featured_people", :force => true do |t|
    t.integer  "person_id"
    t.text     "text"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "formageddon_browser_states", :force => true do |t|
    t.text     "uri"
    t.text     "cookie_jar"
    t.text     "raw_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formageddon_contact_steps", :force => true do |t|
    t.integer "formageddon_recipient_id"
    t.string  "formageddon_recipient_type"
    t.integer "step_number"
    t.string  "command"
  end

  add_index "formageddon_contact_steps", ["formageddon_recipient_id", "formageddon_recipient_type"], :name => "formageddon_cs_recipient_index"

  create_table "formageddon_delivery_attempts", :force => true do |t|
    t.integer  "formageddon_letter_id"
    t.string   "result"
    t.integer  "letter_contact_step"
    t.text     "before_browser_state_id"
    t.text     "after_browser_state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formageddon_delivery_attempts", ["formageddon_letter_id"], :name => "index_formageddon_delivery_attempts_on_formageddon_letter_id"

  create_table "formageddon_form_captcha_images", :force => true do |t|
    t.integer "formageddon_form_id"
    t.integer "image_number"
    t.string  "css_selector"
  end

  add_index "formageddon_form_captcha_images", ["formageddon_form_id"], :name => "index_formageddon_form_captcha_images_on_formageddon_form_id"

  create_table "formageddon_form_fields", :force => true do |t|
    t.integer "formageddon_form_id"
    t.integer "field_number"
    t.string  "name"
    t.string  "value"
  end

  add_index "formageddon_form_fields", ["formageddon_form_id"], :name => "index_formageddon_form_fields_on_formageddon_form_id"

  create_table "formageddon_forms", :force => true do |t|
    t.integer "formageddon_contact_step_id"
    t.integer "form_number"
    t.boolean "use_field_names"
    t.string  "success_string"
    t.boolean "use_real_email_address",      :default => false
  end

  add_index "formageddon_forms", ["formageddon_contact_step_id"], :name => "index_formageddon_forms_on_formageddon_contact_step_id"

  create_table "formageddon_letters", :force => true do |t|
    t.integer  "formageddon_thread_id"
    t.string   "direction"
    t.string   "status"
    t.string   "issue_area"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formageddon_letters", ["formageddon_thread_id"], :name => "index_formageddon_letters_on_formageddon_thread_id"
  add_index "formageddon_letters", ["status"], :name => "index_formageddon_letters_on_status"

  create_table "formageddon_threads", :force => true do |t|
    t.integer  "formageddon_recipient_id"
    t.string   "formageddon_recipient_type"
    t.string   "sender_title"
    t.string   "sender_first_name"
    t.string   "sender_last_name"
    t.string   "sender_address1"
    t.string   "sender_address2"
    t.string   "sender_city"
    t.string   "sender_state"
    t.string   "sender_zip5"
    t.string   "sender_zip4"
    t.string   "sender_phone"
    t.string   "sender_email"
    t.string   "privacy"
    t.integer  "formageddon_sender_id"
    t.string   "formageddon_sender_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formageddon_threads", ["formageddon_recipient_id", "formageddon_recipient_type"], :name => "formageddon_t_recipient_index"

  create_table "friend_emails", :force => true do |t|
    t.integer  "emailable_id",   :null => false
    t.string   "emailable_type"
    t.datetime "created_at"
    t.string   "ip_address"
  end

  add_index "friend_emails", ["created_at"], :name => "friend_emails_created_at_index"
  add_index "friend_emails", ["ip_address"], :name => "friend_emails_ip_address_index"

  create_table "friend_invites", :force => true do |t|
    t.integer  "inviter_id"
    t.string   "invitee_email"
    t.datetime "created_at"
    t.string   "invite_key"
  end

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
  end

  create_table "fundraisers", :force => true do |t|
    t.integer  "sunlight_id"
    t.integer  "person_id"
    t.string   "host"
    t.string   "beneficiaries"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "venue"
    t.string   "entertainment_type"
    t.string   "venue_address1"
    t.string   "venue_address2"
    t.string   "venue_city"
    t.string   "venue_state"
    t.string   "venue_zipcode"
    t.string   "venue_website"
    t.string   "contributions_info"
    t.string   "latlong"
    t.string   "rsvp_info"
    t.string   "distribution_payer"
    t.string   "make_checks_payable_to"
    t.string   "checks_payable_address"
    t.string   "committee_id"
  end

  add_index "fundraisers", ["person_id"], :name => "index_fundraisers_on_person_id"

  create_table "gossip", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "email"
    t.string   "link"
    t.text     "tip"
    t.boolean  "frontpage",  :default => false
    t.boolean  "approved",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gpo_billtext_timestamps", :force => true do |t|
    t.integer  "session"
    t.string   "bill_type"
    t.integer  "number"
    t.string   "version"
    t.datetime "created_at"
  end

  create_table "group_bill_positions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "bill_id"
    t.string   "position"
    t.string   "comment"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_invites", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.string   "email"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_members", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.string   "status"
    t.boolean  "receive_owner_emails", :default => true
    t.datetime "last_view"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["group_id"], :name => "index_group_members_on_group_id"
  add_index "group_members", ["user_id"], :name => "index_group_members_on_user_id"

  create_table "groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "join_type"
    t.string   "invite_type"
    t.string   "post_type"
    t.boolean  "publicly_visible",         :default => true
    t.string   "website"
    t.integer  "pvs_category_id"
    t.string   "group_image_file_name"
    t.string   "group_image_content_type"
    t.integer  "group_image_file_size"
    t.datetime "group_image_updated_at"
    t.integer  "state_id"
    t.integer  "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hot_bill_categories", :force => true do |t|
    t.string "name"
  end

  create_table "industry_stats", :id => false, :force => true do |t|
    t.integer  "sector_id",          :null => false
    t.datetime "entered_top_viewed"
  end

  create_table "issue_stats", :id => false, :force => true do |t|
    t.integer  "subject_id",         :null => false
    t.datetime "entered_top_viewed"
  end

  create_table "issues", :force => true do |t|
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "mailing_list_items", :force => true do |t|
    t.string   "mailable_type"
    t.integer  "mailable_id"
    t.integer  "user_mailing_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notebook_items", :force => true do |t|
    t.integer  "political_notebook_id"
    t.string   "type"
    t.string   "url"
    t.string   "title"
    t.string   "date"
    t.string   "source"
    t.text     "description"
    t.boolean  "is_internal"
    t.text     "embed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "filename"
    t.string   "content_type"
    t.string   "thumbnail"
    t.string   "notebookable_type"
    t.integer  "notebookable_id"
    t.integer  "hot_bill_category_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "group_user_id"
  end

  add_index "notebook_items", ["political_notebook_id"], :name => "index_notebook_items_on_political_notebook_id"

  create_table "object_aggregates", :force => true do |t|
    t.string  "aggregatable_type"
    t.integer "aggregatable_id"
    t.date    "date"
    t.integer "page_views_count",    :default => 0
    t.integer "comments_count",      :default => 0
    t.integer "blog_articles_count", :default => 0
    t.integer "news_articles_count", :default => 0
    t.integer "bookmarks_count",     :default => 0
    t.integer "votes_support",       :default => 0
    t.integer "votes_oppose",        :default => 0
  end

  add_index "object_aggregates", ["aggregatable_type", "aggregatable_id"], :name => "aggregatable_poly_idx"
  add_index "object_aggregates", ["date", "aggregatable_type"], :name => "aggregatable_date_type_idx"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "panel_referrers", :force => true do |t|
    t.text     "referrer_url",                :null => false
    t.string   "panel_type"
    t.integer  "views",        :default => 0
    t.datetime "updated_at"
  end

  add_index "panel_referrers", ["panel_type"], :name => "panel_referrers_panel_type_index"
  add_index "panel_referrers", ["referrer_url"], :name => "panel_referrers_referrer_url_index"

  create_table "people", :force => true do |t|
    t.string   "firstname"
    t.string   "middlename"
    t.string   "lastname"
    t.string   "nickname"
    t.date     "birthday"
    t.string   "gender",                    :limit => 1
    t.string   "religion"
    t.string   "url"
    t.string   "party"
    t.string   "osid"
    t.string   "bioguideid"
    t.string   "title"
    t.string   "state"
    t.string   "district"
    t.string   "name"
    t.string   "email"
    t.tsvector "fti_names"
    t.float    "user_approval",                          :default => 5.0
    t.text     "biography"
    t.string   "unaccented_name"
    t.string   "metavid_id"
    t.string   "youtube_id"
    t.string   "website"
    t.string   "congress_office"
    t.string   "phone"
    t.string   "fax"
    t.string   "contact_webform"
    t.string   "sunlight_nickname"
    t.string   "watchdog_id"
    t.integer  "page_views_count"
    t.integer  "news_article_count",                     :default => 0
    t.integer  "blog_article_count",                     :default => 0
    t.integer  "total_session_votes"
    t.integer  "votes_democratic_position"
    t.integer  "votes_republican_position"
  end

  add_index "people", ["firstname", "lastname"], :name => "people_firstname_index"
  add_index "people", ["fti_names"], :name => "people_fti_names_index"

  create_table "people_cycle_contributions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "total_raised"
    t.integer  "top_contributor_id"
    t.integer  "top_contributor_amount"
    t.string   "cycle"
    t.datetime "updated_at"
  end

  add_index "people_cycle_contributions", ["person_id"], :name => "people_cycle_contributions_person_id_index"

  create_table "person_approvals", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rating"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "update_at"
  end

  create_table "person_stats", :id => false, :force => true do |t|
    t.integer  "person_id",                               :null => false
    t.datetime "entered_top_viewed"
    t.integer  "votes_most_often_with_id"
    t.integer  "votes_least_often_with_id"
    t.integer  "opposing_party_votes_most_often_with_id"
    t.integer  "same_party_votes_least_often_with_id"
    t.datetime "entered_top_news"
    t.datetime "entered_top_blog"
    t.integer  "sponsored_bills"
    t.integer  "cosponsored_bills"
    t.integer  "sponsored_bills_passed"
    t.integer  "cosponsored_bills_passed"
    t.integer  "sponsored_bills_rank"
    t.integer  "cosponsored_bills_rank"
    t.integer  "sponsored_bills_passed_rank"
    t.integer  "cosponsored_bills_passed_rank"
    t.float    "party_votes_percentage"
    t.integer  "party_votes_percentage_rank"
    t.float    "abstains_percentage"
    t.integer  "abstains"
    t.integer  "abstains_percentage_rank"
  end

  create_table "political_notebooks", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  add_index "political_notebooks", ["group_id"], :name => "index_political_notebooks_on_group_id"

  create_table "privacy_options", :force => true do |t|
    t.integer  "my_full_name",               :default => 0
    t.integer  "my_email",                   :default => 0
    t.integer  "my_last_login_date",         :default => 0
    t.integer  "my_zip_code",                :default => 0
    t.integer  "my_instant_messanger_names", :default => 0
    t.integer  "my_website",                 :default => 0
    t.integer  "my_location",                :default => 0
    t.integer  "about_me",                   :default => 0
    t.integer  "my_actions",                 :default => 0
    t.integer  "my_tracked_items",           :default => 0
    t.integer  "my_friends",                 :default => 0
    t.integer  "my_congressional_district",  :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "my_political_notebook",      :default => 2
    t.integer  "watchdog",                   :default => 2
  end

  add_index "privacy_options", ["user_id"], :name => "index_privacy_options_on_user_id"

  create_table "pvs_categories", :force => true do |t|
    t.string  "name"
    t.integer "pvs_id"
  end

  create_table "pvs_category_mappings", :force => true do |t|
    t.integer "pvs_category_id"
    t.integer "pvs_category_mappable_id"
    t.string  "pvs_category_mappable_type"
  end

  create_table "refers", :force => true do |t|
    t.string  "label"
    t.string  "ref"
    t.integer "action_id"
  end

  create_table "roles", :force => true do |t|
    t.integer "person_id"
    t.string  "role_type"
    t.date    "startdate"
    t.date    "enddate"
    t.string  "party"
    t.string  "state"
    t.string  "district"
    t.string  "url"
    t.string  "address"
    t.string  "phone"
    t.string  "email"
  end

  add_index "roles", ["person_id"], :name => "index_roles_on_person_id"

  create_table "roll_call_votes", :force => true do |t|
    t.string  "vote"
    t.integer "roll_call_id"
    t.integer "person_id"
  end

  add_index "roll_call_votes", ["person_id"], :name => "roll_call_votes_person_id_index"
  add_index "roll_call_votes", ["roll_call_id"], :name => "roll_call_votes_roll_call_id_index"

  create_table "roll_calls", :force => true do |t|
    t.integer  "number"
    t.string   "where"
    t.datetime "date"
    t.datetime "updated"
    t.string   "roll_type"
    t.text     "question"
    t.string   "required"
    t.string   "result"
    t.integer  "bill_id"
    t.integer  "amendment_id"
    t.string   "filename"
    t.integer  "ayes",                :default => 0
    t.integer  "nays",                :default => 0
    t.integer  "abstains",            :default => 0
    t.integer  "presents",            :default => 0
    t.boolean  "democratic_position"
    t.boolean  "republican_position"
    t.boolean  "is_hot",              :default => false
    t.string   "title"
    t.datetime "hot_date"
    t.integer  "page_views_count"
  end

  add_index "roll_calls", ["amendment_id"], :name => "index_roll_calls_on_amendment_id"
  add_index "roll_calls", ["bill_id"], :name => "index_roll_calls_on_bill_id"
  add_index "roll_calls", ["where", "number", "date"], :name => "index_roll_calls_on_where_and_number_and_date"

  create_table "searches", :force => true do |t|
    t.string   "search_text"
    t.datetime "created_at"
  end

  create_table "sidebar_boxes", :force => true do |t|
    t.string  "image_url"
    t.text    "box_html"
    t.integer "sidebarable_id"
    t.string  "sidebarable_type"
  end

  add_index "sidebar_boxes", ["sidebarable_id", "sidebarable_type"], :name => "sidebarable_poly_idx"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_text_pages", :force => true do |t|
    t.string  "page_params"
    t.string  "title_tags"
    t.text    "meta_description"
    t.string  "meta_keywords"
    t.text    "title_desc"
    t.text    "page_text_editable_type"
    t.integer "page_text_editable_id"
  end

  create_table "site_texts", :force => true do |t|
    t.string   "text_type"
    t.text     "text"
    t.datetime "updated_at"
  end

  add_index "site_texts", ["text_type"], :name => "site_texts_text_type_index"

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_relations", :force => true do |t|
    t.integer "subject_id"
    t.integer "related_subject_id"
    t.integer "relation_count"
  end

  add_index "subject_relations", ["subject_id", "related_subject_id", "relation_count"], :name => "subject_relations_subject_id_index"

  create_table "subjects", :force => true do |t|
    t.string   "term"
    t.integer  "bill_count"
    t.tsvector "fti_names"
    t.integer  "page_views_count"
  end

  add_index "subjects", ["fti_names"], :name => "subject_fti_names_index"
  add_index "subjects", ["term"], :name => "subjects_term_index"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "talking_points", :force => true do |t|
    t.integer  "talking_pointable_id"
    t.string   "talking_pointable_type"
    t.text     "talking_point"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "include_in_message_body", :default => false
  end

  create_table "twitter_configs", :force => true do |t|
    t.integer  "user_id"
    t.string   "secret"
    t.string   "token"
    t.boolean  "tracking"
    t.boolean  "bill_votes"
    t.boolean  "person_approvals"
    t.boolean  "new_notebook_items"
    t.boolean  "logins"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "upcoming_bills", :force => true do |t|
    t.text     "title"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.tsvector "fti_names"
  end

  add_index "upcoming_bills", ["fti_names"], :name => "upcoming_bill_fti_names_index"

  create_table "user_audits", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "email_was"
    t.string   "full_name"
    t.string   "district"
    t.string   "zipcode"
    t.string   "state"
    t.datetime "created_at"
    t.boolean  "processed",  :default => false, :null => false
    t.boolean  "mailing",    :default => false, :null => false
  end

  create_table "user_ip_addresses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "addr",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_mailing_lists", :force => true do |t|
    t.integer  "user_id"
    t.datetime "last_processed"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", :force => true do |t|
    t.string  "name",                  :default => ""
    t.boolean "can_blog",              :default => false
    t.boolean "can_administer_users",  :default => false
    t.boolean "can_see_stats",         :default => false
    t.boolean "can_manage_text",       :default => false
    t.boolean "can_moderate_articles", :default => false
    t.boolean "can_edit_blog_tags",    :default => false
  end

  create_table "user_warnings", :force => true do |t|
    t.integer  "user_id"
    t.text     "warning_message"
    t.integer  "warned_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.boolean  "admin",                              :default => false
    t.boolean  "blog_author",                        :default => false
    t.string   "full_name"
    t.string   "email"
    t.string   "crypted_password",     :limit => 40
    t.string   "salt",                 :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "status"
    t.datetime "last_login"
    t.string   "location"
    t.boolean  "show_email",                         :default => false
    t.boolean  "show_homepage",                      :default => false
    t.string   "homepage"
    t.boolean  "subscribed",                         :default => false
    t.string   "activation_code",      :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",  :limit => 40
    t.string   "zipcode",              :limit => 5
    t.boolean  "mailing",                            :default => false
    t.boolean  "accept_terms"
    t.text     "about"
    t.string   "main_picture"
    t.string   "small_picture"
    t.string   "chat_aim"
    t.string   "chat_yahoo"
    t.string   "chat_msn"
    t.string   "chat_icq"
    t.string   "chat_gtalk"
    t.boolean  "show_aim",                           :default => false
    t.boolean  "show_full_name",                     :default => false
    t.integer  "default_filter",                     :default => 5
    t.integer  "user_role_id",                       :default => 0
    t.boolean  "enabled",                            :default => true
    t.integer  "representative_id"
    t.string   "zip_four",             :limit => 4
    t.datetime "previous_login_date"
    t.string   "identity_url"
    t.string   "feed_key"
    t.text     "district_cache"
    t.text     "state_cache"
    t.boolean  "is_banned",                          :default => false
    t.boolean  "accepted_tos",                       :default => false
    t.datetime "accepted_tos_at"
    t.boolean  "partner_mailing",                    :default => false
    t.string   "authentication_token"
    t.string   "facebook_uid"
  end

  add_index "users", ["email"], :name => "u_email", :unique => true
  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["login"], :name => "u_users", :unique => true
  add_index "users", ["zip_four"], :name => "index_users_on_zip_four"
  add_index "users", ["zipcode"], :name => "index_users_on_zipcode"

  create_table "videos", :force => true do |t|
    t.integer  "person_id"
    t.integer  "bill_id"
    t.text     "embed"
    t.string   "title"
    t.string   "source"
    t.date     "video_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "url"
    t.integer  "length"
  end

  add_index "videos", ["bill_id"], :name => "index_videos_on_bill_id"
  add_index "videos", ["embed"], :name => "index_videos_on_embed"
  add_index "videos", ["person_id"], :name => "index_videos_on_person_id"
  add_index "videos", ["url"], :name => "index_videos_on_url"

  create_table "watch_dogs", :force => true do |t|
    t.integer  "district_id"
    t.integer  "user_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wiki_links", :force => true do |t|
    t.string   "wikiable_type"
    t.integer  "wikiable_id"
    t.string   "name"
    t.string   "oc_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "write_rep_email_msgids", :force => true do |t|
    t.integer  "write_rep_email_id"
    t.integer  "person_id"
    t.string   "status"
    t.integer  "msgid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "write_rep_emails", :force => true do |t|
    t.integer  "user_id"
    t.string   "prefix"
    t.string   "fname"
    t.string   "lname"
    t.string   "address"
    t.string   "zip5"
    t.string   "zip4"
    t.string   "city"
    t.string   "state"
    t.string   "district"
    t.integer  "person_id"
    t.string   "email"
    t.string   "phone"
    t.string   "subject"
    t.text     "msg"
    t.string   "result"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zipcode_districts", :id => false, :force => true do |t|
    t.string  "zip5",     :limit => 5, :null => false
    t.string  "zip4",     :limit => 4, :null => false
    t.string  "state",    :limit => 2
    t.integer "district", :limit => 2
  end

  add_index "zipcode_districts", ["state"], :name => "index_zipcode_districts_on_state"

end
