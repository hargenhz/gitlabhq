require "spec_helper"

describe Gitlab::GoogleCodeImport::Importer do
  let(:raw_data) { JSON.parse(File.read(Rails.root.join("spec/fixtures/GoogleCodeProjectHosting.json"))) }
  let(:client) { Gitlab::GoogleCodeImport::Client.new(raw_data) }
  let(:import_data) { client.repo("tint2").raw_data }
  let(:project) { create(:project, import_data: import_data) }
  subject { described_class.new(project) }

  describe "#execute" do
    it "imports status labels" do
      subject.execute

      %w(New NeedInfo Accepted Wishlist Started Fixed Invalid Duplicate WontFix Incomplete).each do |status|
        expect(project.labels.find_by(name: "Status: #{status}")).to_not be_nil
      end
    end

    it "imports labels" do
      subject.execute

      %w(
        Type-Defect Type-Enhancement Type-Task Type-Review Type-Other Milestone-0.12 Priority-Critical 
        Priority-High Priority-Medium Priority-Low OpSys-All OpSys-Windows OpSys-Linux OpSys-OSX Security 
        Performance Usability Maintainability Component-Panel Component-Taskbar Component-Battery 
        Component-Systray Component-Clock Component-Launcher Component-Tint2conf Component-Docs Component-New
      ).each do |label|
        label.sub!("-", ": ")
        expect(project.labels.find_by(name: label)).to_not be_nil
      end
    end

    it "imports issues" do
      subject.execute

      issue = project.issues.first
      expect(issue).to_not be_nil
      expect(issue.iid).to eq(169)
      expect(issue.state).to eq("closed")
      expect(issue.label_names).to include("Priority: Medium")
      expect(issue.label_names).to include("Status: Fixed")
      expect(issue.label_names).to include("Type: Enhancement")
      expect(issue.title).to eq("Scrolling through tasks")
      expect(issue.state).to eq("closed")
      expect(issue.description).to include("schattenpr...")
      expect(issue.description).to include("November 18, 2009 00:20")
      expect(issue.description).to include('I like to scroll through the tasks with my scrollwheel \(like in fluxbox\).')
      expect(issue.description).to include('Patch is attached that adds two new mouse\-actions \(next\_taskprev\_task\)')
      expect(issue.description).to include('that can be used for exactly that purpose.')
      expect(issue.description).to include('all the best!')
      expect(issue.description).to include('[tint2_task_scrolling.diff](https://storage.googleapis.com/google-code-attachments/tint2/issue-169/comment-0/tint2_task_scrolling.diff)')
      expect(issue.description).to include('![screenshot.png](https://storage.googleapis.com/google-code-attachments/tint2/issue-169/comment-0/screenshot.png)')
    end

    it "imports issue comments" do
      subject.execute

      note = project.issues.first.notes.first
      expect(note).to_not be_nil
      expect(note.note).to include("Comment 1")
      expect(note.note).to include("thilo...")
      expect(note.note).to include("November 18, 2009 05:14")
      expect(note.note).to include("applied, thanks.")
      expect(note.note).to include("Status: Fixed")
      expect(note.note).to include("~~Type: Defect~~")
      expect(note.note).to include("Type: Enhancement")
    end
  end
end
