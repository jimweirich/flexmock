class FlexMock
  module Version
    NUMBERS = [
      MAJOR = 1,
      MINOR = 4,
      BUILD = 0,
      'beta', 1
    ]
  end

  VERSION = Version::NUMBERS.join('.')
end
