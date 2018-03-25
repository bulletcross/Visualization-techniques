
function [X, im_channels] = FeaturizeImage(im, mask)

im_channels = ChannelizeImage(im, mask);

if isa(im, 'float')
  assert(all(im(:) <= 1));
  assert(all(im(:) >= 0));
end

X = {};
for i_channel = 1:length(im_channels)

  im_channel = im_channels{i_channel};

  log_im_channel = {};
  for c = 1:size(im_channel, 3)
    log_im_channel{c} = log(double(im_channel(:,:,c)));
  end
  u = log_im_channel{2} - log_im_channel{1};
  v = log_im_channel{2} - log_im_channel{3};

  valid = ~isinf(u) & ~isinf(v) & ~isnan(u) & ~isnan(v) & mask;

  if isa(im, 'float')
    min_val = 1/256;
  else
    min_val = intmax(class(im)) * (1/256);
  end
  valid = valid & all(im_channel >= min_val, 3);

  %TODO - change the function to original hist eqaution
  Xc = Psplat2(u(valid), v(valid), ones(nnz(valid),1), ...
    -6, 0.025,256);

  Xc = Xc / max(eps, sum(Xc(:)));

  X{end+1} = Xc;
end

X = cat(3, X{:});

end