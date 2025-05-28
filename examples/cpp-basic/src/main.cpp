#include <iostream>
#include <fstream>
#include <string>
#include <google/protobuf/util/time_util.h>
#include <google/protobuf/util/json_util.h>
#include "example/v1/person.pb.h"

using example::v1::Person;
using example::v1::AddressBook;
using google::protobuf::util::TimeUtil;
using google::protobuf::util::JsonPrintOptions;
using google::protobuf::util::MessageToJsonString;

// Function to create a sample person
Person create_person() {
    Person person;
    person.set_name("John Doe");
    person.set_id(1234);
    person.set_email("john.doe@example.com");
    
    // Add phone numbers
    auto* phone1 = person.add_phones();
    phone1->set_number("+1-555-1234");
    phone1->set_type(Person::MOBILE);
    
    auto* phone2 = person.add_phones();
    phone2->set_number("+1-555-5678");
    phone2->set_type(Person::WORK);
    
    // Set timestamp
    *person.mutable_last_updated() = TimeUtil::GetCurrentTime();
    
    return person;
}

// Function to print person information
void print_person(const Person& person) {
    std::cout << "Person Information:" << std::endl;
    std::cout << "  Name: " << person.name() << std::endl;
    std::cout << "  ID: " << person.id() << std::endl;
    std::cout << "  Email: " << person.email() << std::endl;
    
    for (const auto& phone : person.phones()) {
        std::cout << "  Phone: " << phone.number();
        switch (phone.type()) {
            case Person::MOBILE:
                std::cout << " (Mobile)";
                break;
            case Person::HOME:
                std::cout << " (Home)";
                break;
            case Person::WORK:
                std::cout << " (Work)";
                break;
            default:
                std::cout << " (Unknown)";
                break;
        }
        std::cout << std::endl;
    }
    
    if (person.has_last_updated()) {
        std::cout << "  Last Updated: " 
                  << TimeUtil::ToString(person.last_updated()) 
                  << std::endl;
    }
}

int main(int argc, char* argv[]) {
    // Verify that the version of the library that we linked against is
    // compatible with the version of the headers we compiled against.
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    // Create a person
    Person person = create_person();
    
    // Print person information
    print_person(person);
    std::cout << std::endl;

    // Convert to JSON
    std::string json_output;
    JsonPrintOptions options;
    options.add_whitespace = true;
    options.always_print_primitive_fields = true;
    
    auto status = MessageToJsonString(person, &json_output, options);
    if (status.ok()) {
        std::cout << "Person as JSON:" << std::endl;
        std::cout << json_output << std::endl;
    } else {
        std::cerr << "Failed to convert to JSON: " << status.message() << std::endl;
    }

    // Create an address book with multiple people
    AddressBook address_book;
    *address_book.add_people() = person;
    
    // Add another person
    Person person2;
    person2.set_name("Jane Smith");
    person2.set_id(5678);
    person2.set_email("jane.smith@example.com");
    auto* phone = person2.add_phones();
    phone->set_number("+1-555-9999");
    phone->set_type(Person::HOME);
    *person2.mutable_last_updated() = TimeUtil::GetCurrentTime();
    
    *address_book.add_people() = person2;

    std::cout << "\nAddress Book contains " << address_book.people_size() 
              << " people." << std::endl;

    // Save to file if filename provided
    if (argc > 1) {
        std::fstream output(argv[1], 
            std::ios::out | std::ios::trunc | std::ios::binary);
        if (!address_book.SerializeToOstream(&output)) {
            std::cerr << "Failed to write address book." << std::endl;
            return -1;
        }
        std::cout << "Address book saved to " << argv[1] << std::endl;
    }

    // Clean up
    google::protobuf::ShutdownProtobufLibrary();
    
    return 0;
}