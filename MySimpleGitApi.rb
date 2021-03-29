require 'octokit'

#temp github api token: a9d65691841e987ed8fb91ad1c8cd084d82dd0e9
class MySimpleGitApi

  def self.get_bad_pr
    puts "Searching..."
    client = Octokit::Client.new(:access_token => "a9d65691841e987ed8fb91ad1c8cd084d82dd0e9", :per_page => 300)

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
        #if the suspect commits modified rows number is more than the pull modified rows number, then the same rows is modifield in more than one commit
        if filenames.detect{|e| filenames.count(e) > 1} != nil && client.pull_files(repo, pull.number).map(&:patch).flatten.filter_map{|d| d.split('@@').select{|s| s.length >10 && s.length < 25} unless d.nil?}.flatten.length < sus_commits.map{|c|c.files.map(&:patch)}.flatten.filter_map{|d| d.split('@@').select{|s| s.length > 10 && s.length < 25} unless d.nil?}.flatten.length
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
