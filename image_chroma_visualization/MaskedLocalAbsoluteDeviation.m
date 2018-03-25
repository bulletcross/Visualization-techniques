
function im_edge = MaskedLocalAbsoluteDeviation(im, mask)

im_class = class(im);

if strcmp(im_class, 'uint16')
  % Upgrade to 32-bit because we have minus here
  im = int32(im);
  im_pad = Pad1(im);
  mask = int32(mask);
  mask_pad = Pad1(mask);
elseif strcmp(im_class, 'uint8')
  % Upgrade to 16-bit because we have minus here
  im = int16(im);
  im_pad = Pad1(im);
  mask = int16(mask);
  mask_pad = Pad1(mask);
elseif strcmp(im_class, 'double')
  im_pad = Pad1(im);
  mask_pad = Pad1(mask);
else
  assert(0)
end

im_edge = {};
for c = 1:size(im,3)
  numer = zeros(size(im,1), size(im,2), 'like', im);
  denom = zeros(size(im,1), size(im,2), 'like', im);
  for oi = -1:1
    for oj = -1:1
      if (oi == 0) && (oj == 0)
        continue
      end
      im_shift = im_pad([1:size(im,1)] + oi + 1, [1:size(im,2)] + oj + 1, c);
      mask_shift = mask_pad([1:size(im,1)] + oi + 1, [1:size(im,2)] + oj + 1);
      numer = numer + mask .* mask_shift .* abs(im_shift - im(:,:,c));
      denom = denom + mask .* mask_shift;
    end
  end
  if strcmp(im_class, 'double')
    im_edge{c} = numer ./ denom;
  else
    % This divide is ugly to make it match up with the non-masked code.
    im_edge{c} = bitshift(bitshift(numer, 3) ./ denom, -3);
  end
end
im_edge = cat(3, im_edge{:});

if strcmp(im_class, 'uint16')
  % Convert back to 16-bit
  im_edge = uint16(im_edge);
elseif strcmp(im_class, 'uint8')
  % Convert back to 8-bit
  im_edge = uint8(im_edge);
end
