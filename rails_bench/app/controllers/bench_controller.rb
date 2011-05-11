OBJECTS_COUNT = 50

User = Struct.new(:id, :login, :password, :age)
class User
  include HammerBuilder::Helper

  builder :menu do |user|
    li { a(user.login).href("user/#{user.id}") }
  end

  builder :detail do |user|
    li do
      ul.class('user').id("user-#{user.id}") do
        li user.id
        li user.login
        li user.password
        li user.age
      end
    end
  end
end

USERS = Array.new(OBJECTS_COUNT) do |i|
  User.new i, rand(10000000).to_s(36), rand(10000000).to_s(16), rand(60)+10
end

Comment = Struct.new(:id, :subject, :content)
class Comment
  include HammerBuilder::Helper

  builder :menu do |comment|
    li { a(comment.subject).href("comment/#{comment.id}") }
  end

  builder :detail do |comment|
    li do
      ul.class('comment').id("comment-#{comment.id}") do
        li comment.id
        li comment.subject
        li comment.content
      end
    end
  end
end
COMMENTS = Array.new(OBJECTS_COUNT) do |i|
  Comment.new i, rand(10000000).to_s(36), rand(10000000).to_s(36)*50
end

module Tenjin::ContextHelper
  def import(template_name, _append_to_buf=true, context_update = {})
    update(context_update)
    _buf = self._buf
    output = self._engine.render(template_name, context = self, layout=false)
    _buf << output if _append_to_buf
    return output
  end
end

class BenchController < ApplicationController
  layout false

  def erubis_partials
  end

  def erubis_single
  end

  def tenjin_single
    @tenjin_single ||= Tenjin::Engine.new(:path => ["#{Rails.root}/app/views/bench/"])
    render :text => @tenjin_single.render('tenjin_single.rbhtml')
  end

  def tenjin_partial
    @tenjin_partial ||= Tenjin::Engine.new(:path => ["#{Rails.root}/app/views/bench/"])
    render :text => @tenjin_partial.render('tenjin_partial.rbhtml')
  end

  def hammer_builder
    render :text => builder_page(HammerBuilder::Standard.get).to_xhtml!
  end

  private

  include HammerBuilder::Helper

  builder :builder_page do |_|
    xhtml5!
    html do
      head { title 'Comunity' }
      body do
        div(:id => 'menu') do
          ul.class('menu') do
            li do
              ul.class('menu').id(:users) do
                USERS.each do |user|
                  user.menu self
                end
              end
            end
            li do
              ul.class('menu').id(:comments) do
                COMMENTS.each do |comment|
                  comment.menu self
                end
              end
            end
          end
        end
        div :id => 'content' do
          div :class => 'list' do
            ul do
              USERS.each do |user|
                user.detail self
              end
            end
          end
          div :class => 'list' do
            ul do
              COMMENTS.each do |comment|
                comment.detail self
              end
            end
          end
        end
      end
    end
  end

end
