require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Capistrano::Mountaintop, "loaded into capistrano" do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    Capistrano::Mountaintop.load_into(@configuration)

    @campfire_room = mock('campfire room')

    @configuration.set(:campfire_room, @campfire_room)
  end

  it "defines mountaintop:campfire:starting" do
    @configuration.find_task('mountaintop:campfire:starting').should_not == nil
  end

  it "defines mountaintop:campfire:finished" do
    @configuration.find_task('mountaintop:campfire:finished').should_not == nil
  end

  it "performs mountain:campfire:starting before deploy" do
    @configuration.should callback('mountaintop:campfire:starting').before('deploy')
  end

  it "performs mountain:announce:finished after deploy" do
    @configuration.should callback('mountaintop:campfire:finished').after('deploy')
  end

  context "in multistage environment" do
    specify "mountaintop:campfire:begin speaks the user deploying, the branch being deployed, and the stage being deployed to" do
      @configuration.set(:deployer, "Zim")
      @configuration.set(:application, "worlddomination")
      @configuration.set(:branch, "master")
      @configuration.set(:stage, "staging")
      @campfire_room.should_receive(:speak).with("Zim is deploying worlddomination's master to staging")
      
      @configuration.find_and_execute_task('mountaintop:campfire:starting')
    end

    specify "mountaintop:campfire:finish pastes the full log" do
      @configuration.set(:full_log, "I AM A LOG")
      @campfire_room.should_receive(:paste).with("I AM A LOG")

      @configuration.find_and_execute_task('mountaintop:campfire:finished')
    end
  end

  context "in non-multistage environment" do
    specify "mountaintop:announce:begin speaks the user deploying and the branch being deployed to production" do
      @configuration.set(:deployer, "Zim")
      @configuration.set(:application, "worlddomination")
      @configuration.set(:branch, "master")
      @campfire_room.should_receive(:speak).with("Zim is deploying worlddomination's master to production")

      @configuration.find_and_execute_task('mountaintop:campfire:starting')
    end
      

    specify "mountaintop:announce:finish pastes the full log" do
      @configuration.set(:full_log, "I AM A LOG")
      @campfire_room.should_receive(:paste).with("I AM A LOG")

      @configuration.find_and_execute_task('mountaintop:campfire:finished')
    end
  end
end
