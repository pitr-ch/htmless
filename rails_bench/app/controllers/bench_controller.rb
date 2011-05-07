class BenchController < ApplicationController
  layout false

  def erubis_partials
  end

  def erubis_single
  end

  def hammer_builder
    tmp = lambda do
      xhtml5!
      html do
        head { title 'Comunity' }
        body do
          div(:id => 'menu') do
            ul.class('menu') do
              li do
                ul.class('menu').id(:users) do
                  USERS.each do |user|
                    li { a(user.login).href("user/#{user.id}") }
                  end
                end
              end
              li do
                ul.class('menu').id(:comments) do
                  COMMENTS.each do |comment|
                    li { a(comment.subject).href("comment/#{comment.id}") }
                  end
                end
              end
            end
          end
          div :id => 'content' do
            div :class => 'list' do
              ul do
                USERS.each do |user|
                  ul.class('user').id("user-#{user.id}") do
                    li user.id
                    li user.login
                    li user.password
                    li user.age
                  end
                end
              end
            end
            div :class => 'list' do
              ul do
                COMMENTS.each do |comment|
                  ul.class('comment').id("comment-#{comment.id}") do
                    li comment.id
                    li comment.subject
                    li comment.content
                  end
                end
              end
            end
          end
        end
      end
    end
    render :text => HammerBuilder::Standard.get.go_in(&tmp).to_html!
  end

end
