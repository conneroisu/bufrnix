// This is a placeholder import for the proto-generated files
// After generating the protos, the imports will be valid

// Option 1: Standard JavaScript (CommonJS)
// import { User } from '../proto/gen/js/example/v1/example_pb';
// import { UserServiceClient } from '../proto/gen/js/example/v1/example_grpc_web_pb';

// Option 2: Modern ECMAScript modules
// import { User } from '../proto/gen/js/example/v1/example';

// Option 3: Connect-ES client
// import { UserService } from '../proto/gen/js/example/v1/example_connect';

async function main() {
  console.log('JavaScript Example for Bufrnix');
  
  // Example code using CommonJS imports
  /*
  // Create a new user using CommonJS style
  const user = new User();
  user.setId('1');
  user.setName('John Doe');
  user.setEmail('john@example.com');
  user.setAge(30);

  console.log('Created user (CommonJS):', {
    id: user.getId(),
    name: user.getName(),
    email: user.getEmail(),
    age: user.getAge()
  });

  // Example of using the gRPC-web client
  const grpcClient = new UserServiceClient('http://localhost:8080');
  */

  // Example code using ES module imports
  /*
  // Create a new user using ES module style
  const userEs = {
    id: '2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    age: 28
  };
  
  console.log('Created user (ES Modules):', userEs);
  
  // Example of using Connect client
  const connectClient = new UserService({
    baseUrl: 'http://localhost:8080'
  });
  */
}

main().catch(console.error);