//
// DECODERS
//

// Extracts the footfall count and the battery status.
function Decoder(bytes, port) {
  var decoded = {};
  decoded.footfall = (bytes[0] << 8) + bytes[1];
  decoded.battery = (bytes[2] << 8) + bytes[3];
  return decoded;
}