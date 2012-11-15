class FlexMock
  module Version
    NUMBERS = [
      MAJOR = 1,
      MINOR = 2,
      BUILD = 0,
    ]
  end

  VERSION = Version::NUMBERS.join('.')
end
