using System;
using Google.Protobuf;
using ExampleProtos.Example.V1;

namespace CSharpExample
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("C# Protocol Buffers Example");
            Console.WriteLine("==========================");
            
            // Create a new Person message
            var person = new Person
            {
                Id = 123,
                Name = "John Doe",
                Email = "john.doe@example.com"
            };
            
            // Add some phone numbers
            person.Phones.Add(new Person.Types.PhoneNumber
            {
                Number = "555-1234",
                Type = Person.Types.PhoneType.Mobile
            });
            
            person.Phones.Add(new Person.Types.PhoneNumber
            {
                Number = "555-5678",
                Type = Person.Types.PhoneType.Work
            });
            
            // Serialize to bytes
            byte[] bytes = person.ToByteArray();
            Console.WriteLine($"\nSerialized to {bytes.Length} bytes");
            
            // Deserialize from bytes
            var deserializedPerson = Person.Parser.ParseFrom(bytes);
            
            // Display the deserialized data
            Console.WriteLine($"\nDeserialized Person:");
            Console.WriteLine($"  ID: {deserializedPerson.Id}");
            Console.WriteLine($"  Name: {deserializedPerson.Name}");
            Console.WriteLine($"  Email: {deserializedPerson.Email}");
            Console.WriteLine($"  Phone Numbers:");
            foreach (var phone in deserializedPerson.Phones)
            {
                Console.WriteLine($"    {phone.Number} ({phone.Type})");
            }
            
            // Create an address book
            var addressBook = new AddressBook();
            addressBook.People.Add(person);
            addressBook.People.Add(new Person
            {
                Id = 456,
                Name = "Jane Smith",
                Email = "jane.smith@example.com"
            });
            
            // Serialize to JSON
            var jsonFormatter = JsonFormatter.Default;
            string json = jsonFormatter.Format(addressBook);
            Console.WriteLine($"\nAddress Book as JSON:");
            Console.WriteLine(json);
            
            // Parse from JSON
            var jsonParser = JsonParser.Default;
            var parsedAddressBook = jsonParser.Parse<AddressBook>(json);
            Console.WriteLine($"\nParsed {parsedAddressBook.People.Count} people from JSON");
        }
    }
}