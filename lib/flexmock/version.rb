class FlexMock
  module Version
    NUMBERS = [
      MAJOR = 1,
      MINOR = 3,
      BUILD = 3,
    ]
  end

  VERSION = Version::NUMBERS.join('.')
end
