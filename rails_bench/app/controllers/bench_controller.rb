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

  def hammer_builder
    render :text => render_page(HammerBuilder::Standard.get).to_xhtml!
  end

  def tenjin_single
    @tenjin_single ||= Tenjin::Engine.new(:path => ["#{Rails.root}/app/views/bench/"])
    render :text => @tenjin_single.render('tenjin_single.rbhtml')
  end

  def tenjin_partial
    @tenjin_partial ||= Tenjin::Engine.new(:path => ["#{Rails.root}/app/views/bench/"])
    render :text => @tenjin_partial.render('tenjin_partial.rbhtml')
  end

  private

  def render_page(b)
    b.go_in(self) do |controller|
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

end
