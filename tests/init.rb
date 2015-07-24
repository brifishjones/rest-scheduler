# invoke test with localhost argv to run locally
@host = ARGV[0].to_s == "localhost" ? "http://localhost:4567" : "https://gentle-brushlands-1205.herokuapp.com"

def run_test (s)
  puts "----------------------------------------------------------------"
  puts s
  system s
  puts
end
