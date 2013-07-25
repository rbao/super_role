def hi(&block)
  puts block
  yield
end

hi(Proc.new { puts 'hi' })