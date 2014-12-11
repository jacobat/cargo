module ApplicationHelper
  def format_logs(logs, limit)
    limit = [50, limit].max
    log_lines = ansi_2_html(logs).split("\n")
    tail_count = [log_lines.length, limit].min
    log_lines.slice(-tail_count, tail_count).map(&:html_safe)
  end

  def ansi_2_html(data)
    { 1 => :nothing,
      2 => :nothing,
      4 => :underline,
      5 => :nothing,
      7 => :nothing,
      30 => :black,
      31 => :red,
      32 => :green,
      33 => :yellow,
      34 => :blue,
      35 => :magenta,
      36 => :cyan,
      37 => :white,
      40 => :nothing,
      41 => :nothing,
      43 => :nothing,
      44 => :nothing,
      45 => :nothing,
      46 => :nothing,
      47 => :nothing,
    }.each do |key, value|
      if value != :nothing
        if value != :underline
          data.gsub!(/\e\[#{key}m/,"<span style=\"color:#{value}\">")
        else
          data.gsub!(/\e\[#{key}m/,"<span style=\"text-decoration:#{value}\">")
        end
      else
        data.gsub!(/\e\[#{key}m/,"<span>")
      end
    end
    data.gsub!(/\e\[0m/,'</span>')
    data.gsub!(/\e\[24m/,'</span>')
    data.gsub!(/\e\[39m/,'</span>')
    return data
  end
end
