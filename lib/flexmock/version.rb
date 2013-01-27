class FlexMock
  module Version
    NUMBERS = [
      MAJOR = 1,
      MINOR = 3,
      BUILD = 0,
    ]
  end

  VERSION = Version::NUMBERS.join('.')
end
