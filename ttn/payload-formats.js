//
// DECODERS
//

//
// Extracts a simple (integer) footfall counter that was encoded in
// the first two payload bytes.
//
function Decoder(bytes, port) {
  var decoded = {};
  decoded.footfall = (bytes[0] << 8) + bytes[1];
  decoded.battery = (bytes[2] << 8) + bytes[3];
  return decoded;
}