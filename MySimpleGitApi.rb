require 'octokit'

#temp github api token: 7b20b36519ecd6349645821d752702672cf39b69
class MySimpleGitApi

  def self.get_bad_pr
    client = Octokit::Client.new(:access_token => "7b20b36519ecd6349645821d752702672cf39b69", per_page: 300)

    end_result = []
    repo = 'rails/rails'
    pulls = client.pulls(repo, :state => 'open')
    pulls.each do |pull|
      pull_commits = client.pull_commits(repo, pull.number)
      sus_commits = []
      #decrease client request
      if pull_commits.length > 1
        pull_commits.each do |commit|
          sus_commits << client.commit(repo, commit.sha)
        end
        filenames = sus_commits.map{|c| c.files.map(&:filename)}.flatten
        if filenames.detect{|e| filenames.count(e) > 1} != nil && client.pull_files(repo, pull.number).map(&:patch).flatten.map{|d| d.split('@@').select{|s| s.length >10 && s.length < 25}}.flatten.length < sus_commits.map{|c|c.files.map(&:patch)}.flatten.map{|d| d.split('@@').select{|s| s.length > 10 && s.length < 25}}.flatten.length
          end_result << pull.html_url
        end
      end
    end

    end_result
  end
end

if __FILE__ == $0
  puts MySimpleGitApi.get_bad_pr
end
