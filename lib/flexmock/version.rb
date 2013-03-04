class FlexMock
  module Version
    NUMBERS = [
      MAJOR = 1,
      MINOR = 3,
      BUILD = 1,
    ]
  end

  VERSION = Version::NUMBERS.join('.')
end
