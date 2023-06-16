require 'spec_helper'

describe RoutePolicy do
  
  subject { RoutePolicy.new(user, Route) }


  context "for a visitor" do
    # it { should     permit(:show)    }

    it "should allow viewing homepage" do
      permit(:home)
    end

    it "should not allow viewing index page" do
      permit(:index)
    end


    # it { should_not permit(:create)  }
    # it { should_not permit(:new)     }
    # it { should_not permit(:update)  }
    # it { should_not permit(:edit)    }
    # it { should_not permit(:destroy) }
  end

  # context "for a user" do
  #   login_user

  #   it { should permit(:show)    }
  #   it { should permit(:create)  }
  #   it { should permit(:new)     }
  #   it { should permit(:update)  }
  #   it { should permit(:edit)    }
  #   it { should permit(:destroy) }
  # end
end
