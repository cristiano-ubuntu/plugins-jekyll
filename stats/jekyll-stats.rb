module Jekyll
  class StatsPlugin < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @categories = []
      @posts = []
      @words = 0
      @letters = 0
      @last_post = nil
      @most_posts_category = nil
      @most_posts_month = nil
      @most_posts_year = nil
    end

    def render(context)
      @categories = context.registers[:site].data["categories"]
      @posts = context.registers[:site].posts
      @words = @posts.reduce(0) { |sum, post| sum + post.content.split(" ").size }
      @letters = @posts.reduce(0) { |sum, post| sum + post.content.length }
      @last_post = @posts.last
      @most_posts_category = @posts.group_by { |post| post.categories.first }.max_by { |k, v| v.size }.first
      @most_posts_month = @posts.group_by { |post| post.date.strftime("%b") }.max_by { |k, v| v.size }.first
      @most_posts_year = @posts.group_by { |post| post.date.strftime("%Y") }.max_by { |k, v| v.size }.first

      template = File.read(File.expand_path(__dir__ + "/stats.html"))
      Liquid::Template.parse(template).render(context.merge({
        "categories": @categories,
        "posts": @posts,
        "words": @words,
        "letters": @letters,
        "last_post": @last_post,
        "most_posts_category": @most_posts_category,
        "most_posts_month": @most_posts_month,
        "most_posts_year": @most_posts_year
      }))
    end
  end

  Liquid::Template.register_tag("stats", StatsPlugin)
end
