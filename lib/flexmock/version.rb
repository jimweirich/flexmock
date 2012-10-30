class FlexMock
  module Version
    NUMBERS = [
      MAJOR = 1,
      MINOR = 1,
      BUILD = 0,
    ]
  end

  VERSION = Version::NUMBERS.join('.')
end
