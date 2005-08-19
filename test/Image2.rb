#! /usr/local/bin/ruby -w

require 'RMagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

# TODO: improve exif tests - need a benchmark image with EXIF data


class Image2_UT < Test::Unit::TestCase
    
    def setup
        @img = Magick::Image.new(20, 20)
    end
    
    def test_composite!
        img1 = Magick::Image.read(IMAGES_DIR+'/Button_0.gif').first
        img2 = Magick::Image.read(IMAGES_DIR+'/Button_1.gif').first
        assert_nothing_raised do
            res = img1.composite!(img2, Magick::NorthWestGravity, Magick::OverCompositeOp)
            assert_same(img1, res)
        end
        img1.freeze
        assert_raise(TypeError) { img1.composite!(img2, Magick::NorthWestGravity, Magick::OverCompositeOp) }
    end
    
    def test_composite_affine
        affine = Magick::AffineMatrix.new(1, 0, 1, 0, 0, 0)
        img1 = Magick::Image.read(IMAGES_DIR+'/Button_0.gif').first
        img2 = Magick::Image.read(IMAGES_DIR+'/Button_1.gif').first
        assert_nothing_raised do
            res = img1.composite_affine(img2, affine)
            assert_instance_of(Magick::Image, res)
        end
    end
    
    def test_compress_colormap!
        # DirectClass images are converted to PseudoClass 
        assert_equal(Magick::DirectClass, @img.class_type)
        assert_nothing_raised { @img.compress_colormap! }
        assert_equal(Magick::PseudoClass, @img.class_type)
        img = Magick::Image.read(IMAGES_DIR+'/Button_0.gif').first
        assert_equal(Magick::PseudoClass, @img.class_type)
        assert_nothing_raised { @img.compress_colormap! }
    end
    
    def test_contrast
        assert_nothing_raised do
            res = @img.contrast
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.contrast(true) }
        assert_raise(ArgumentError) { @img.contrast(true, 2) }
    end
    
    def test_convolve
        kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
        order = 3
        assert_nothing_raised do
            res = @img.convolve(order, kernel)
            assert_instance_of(Magick::Image, res)
        end
        assert_raise(ArgumentError) { @img.convolve }
        assert_raise(ArgumentError) { @img.convolve(order) }
        assert_raise(IndexError) { @img.convolve(5, kernel) }
        assert_raise(IndexError) { @img.convolve(order, "x") }
        assert_raise(TypeError) { @img.convolve(3, [1.0, 1.0, 1.0, 1.0, 'x', 1.0, 1.0, 1.0, 1.0]) }
        assert_raise(Magick::ImageMagickError) { @img.convolve(2, [1.0, 1.0, 1.0, 1.0]) }
    end
    
    def test_convolve_channel
        assert_raise(ArgumentError) { @img.convolve_channel }
        assert_raise(ArgumentError) { @img.convolve_channel(3) }
        kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
        order = 3
        assert_nothing_raised do
            res = @img.convolve_channel(order, kernel, Magick::RedChannel)
            assert_instance_of(Magick::Image, res)
        end
        
        assert_nothing_raised { @img.convolve_channel(order, kernel, Magick::RedChannel, Magick:: BlueChannel) }
        assert_raise(TypeError) { @img.convolve_channel(order, kernel, Magick::RedChannel, 2) }
    end
    
    def test_copy
        assert_nothing_raised do
            ditto = @img.copy
            assert_equal(@img, ditto)
        end
        ditto = @img.copy
        assert_equal(@img.tainted?, ditto.tainted?)
        @img.taint
        ditto = @img.copy
        assert_equal(@img.tainted?, ditto.tainted?)
    end
    
    def test_crop
        assert_raise(ArgumentError) { @img.crop }
        assert_raise(ArgumentError) { @img.crop(0, 0) }
        assert_nothing_raised do
            res = @img.crop(0, 0, @img.columns/2, @img.rows/2) 
            assert_instance_of(Magick::Image, res)
        end
        gravity = [
                Magick::NorthEastGravity,
                Magick::EastGravity,
                Magick::SouthWestGravity,
                Magick::SouthGravity,
                Magick::SouthEastGravity]
        
        # 3-argument form
        gravity.each do |grav|
            assert_nothing_raised { @img.crop(grav, @img.columns/2, @img.rows/2) }
        end
        assert_raise(TypeError) { @img.crop(2, @img.columns/2, @img.rows/2) }
        assert_raise(TypeError) { @img.crop(Magick::NorthWestGravity, @img.columns/2, @img.rows/2, 2) }
        
        # 4-argument form
        assert_raise(TypeError) { @img.crop(0, 0, @img.columns/2, 'x') }
        assert_raise(TypeError) { @img.crop(0, 0, 'x', @img.rows/2) }
        assert_raise(TypeError) { @img.crop(0, 'x', @img.columns/2, @img.rows/2) }
        assert_raise(TypeError) { @img.crop('x', 0, @img.columns/2, @img.rows/2) }
        assert_raise(TypeError) { @img.crop(0, 0, @img.columns/2, @img.rows/2, 2) }
        
        # 5-argument form
        gravity.each do |grav|
            assert_nothing_raised { @img.crop(grav, 0, 0, @img.columns/2, @img.rows/2) }
        end
        
        assert_raise(ArgumentError) { @img.crop(Magick::NorthWestGravity, 0, 0, @img.columns/2, @img.rows/2, 2) }
    end
    
    def test_crop!
        assert_nothing_raised do
            res = @img.crop!(0, 0, @img.columns/2, @img.rows/2)
            assert_same(@img, res)
        end
    end
    
    def test_cycle_colormap
        assert_nothing_raised do
            res = @img.cycle_colormap(5)
            assert_instance_of(Magick::Image, res)
            assert_equal(Magick::PseudoClass, res.class_type)
        end
    end
    
    def test_despeckle
        assert_nothing_raised do
            res = @img.despeckle
            assert_instance_of(Magick::Image, res)
        end
    end
    
    def test_difference
        img1 = Magick::Image.read(IMAGES_DIR+'/Button_0.gif').first
        img2 = Magick::Image.read(IMAGES_DIR+'/Button_1.gif').first
        assert_nothing_raised do
            res = img1.difference(img2)
            assert_instance_of(Array, res)
            assert_equal(3, res.length)
            assert_instance_of(Float, res[0])
            assert_instance_of(Float, res[1])
            assert_instance_of(Float, res[2])
        end
        
        assert_raise(NoMethodError) { img1.difference(2) }
    end
        
    def test_dup
        assert_nothing_raised do
            ditto = @img.dup
            assert_equal(@img, ditto)
        end
        ditto = @img.dup
        assert_equal(@img.tainted?, ditto.tainted?)
        @img.taint
        ditto = @img.dup
        assert_equal(@img.tainted?, ditto.tainted?)
    end

    def test_each_profile
        @img.iptc_profile = "test profile"
        assert_nothing_raised do
            @img.each_profile do |name, value|
                assert_equal("iptc", name)
                assert_equal("test profile", value)
            end
        end
    end
    
    def test_edge
        assert_nothing_raised do
            res = @img.edge
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.edge(2.0) }
        assert_raise(ArgumentError) { @img.edge(2.0, 2) }
        assert_raise(TypeError) { @img.edge('x') }
    end
    
    def test_emboss
        assert_nothing_raised do
            res = @img.emboss
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.emboss(1.0) }
        assert_nothing_raised { @img.emboss(1.0, 0.5) }
        assert_raise(ArgumentError) { @img.emboss(1.0, 0.5, 2) }
        assert_raise(TypeError) { @img.emboss(1.0, 'x') }
        assert_raise(TypeError) { @img.emboss('x', 1.0) }
    end
    
    def test_enhance
        assert_nothing_raised do
            res = @img.enhance
            assert_instance_of(Magick::Image, res)
        end
    end
    
    
    def test_equalize
        assert_nothing_raised do
            res = @img.equalize
            assert_instance_of(Magick::Image, res)
        end
    end
    
    def test_erase!
        assert_nothing_raised do
            res = @img.erase!
            assert_same(@img, res)
        end
    end
    
    def test_export_pixels
        assert_nothing_raised do
            res = @img.export_pixels(0, 0, @img.columns, 1, 'RGB')
            assert_instance_of(Array, res)
            assert_equal(@img.columns*3, res.length)
            res.each do |p|
                assert_instance_of(Fixnum, p)
            end
        end
    end
    
    def test_flip
        assert_nothing_raised do
            res = @img.flip
            assert_instance_of(Magick::Image, res)
        end
    end
    
    def test_flip!
        assert_nothing_raised do
            res = @img.flip!
            assert_same(@img, res)
        end
    end
    
    def test_flop
        assert_nothing_raised do
            res = @img.flop
            assert_instance_of(Magick::Image, res)
        end
    end
    
    def test_flop!
        assert_nothing_raised do
            res = @img.flop!
            assert_same(@img, res)
        end
    end

    def test_frame
        assert_nothing_raised do
            res = @img.frame
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.frame(50) }
        assert_nothing_raised { @img.frame(50, 50) }
        assert_nothing_raised { @img.frame(50, 50, 25) }
        assert_nothing_raised { @img.frame(50, 50, 25, 25) }
        assert_nothing_raised { @img.frame(50, 50, 25, 25, 6) }
        assert_nothing_raised { @img.frame(50, 50, 25, 25, 6, 6) }
        assert_nothing_raised { @img.frame(50, 50, 25, 25, 6, 6, 'red') }
        red = Magick::Pixel.new(Magick::MaxRGB)
        assert_nothing_raised { @img.frame(50, 50, 25, 25, 6, 6, red) }
        assert_raise(TypeError) { @img.frame(50, 50, 25, 25, 6, 6, 2) }
    end 

    def test_gamma_channel
        assert_nothing_raised do
            res = @img.gamma_channel(0.8)
            assert_instance_of(Magick::Image, res)
        end
        assert_raise(ArgumentError) { @img.gamma_channel }
        assert_nothing_raised { @img.gamma_channel(0.8, Magick::RedChannel) }
        assert_nothing_raised { @img.gamma_channel(0.8, Magick::RedChannel, Magick::BlueChannel) }
        assert_raise(TypeError) { @img.gamma_channel(0.8, Magick::RedChannel, 2) }
    end
    
    def test_gramma_correct
        assert_raise(ArgumentError) { @img.gamma_correct }
        # All 4 arguments can't default to 1.0
        assert_raise(ArgumentError) { @img.gamma_correct(1.0) }
        assert_nothing_raised do
            res = @img.gamma_correct(0.8)
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.gamma_correct(0.8, 0.9) }
        assert_nothing_raised { @img.gamma_correct(0.8, 0.9, 1.0) }
        assert_nothing_raised { @img.gamma_correct(0.8, 0.9, 1.0, 1.1) }
        # too many arguments
        assert_raise(ArgumentError) { @img.gamma_correct(0.8, 0.9, 1.0, 1.1, 2) }
    end
    
    def test_gaussian_blur
        assert_nothing_raised do
            res = @img.gaussian_blur
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.gaussian_blur(0.0) }
        assert_nothing_raised { @img.gaussian_blur(0.0, 3.0) }
        # sigma must be != 0.0
        assert_raise(ArgumentError) { @img.gaussian_blur(1.0, 0.0) }
        assert_raise(ArgumentError) { @img.gaussian_blur(1.0, 3.0, 2) }
    end
    
    def test_gaussian_blur_channel
        assert_nothing_raised do
            res = @img.gaussian_blur_channel
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.gaussian_blur_channel(0.0) }
        assert_nothing_raised { @img.gaussian_blur_channel(0.0, 3.0) }
        assert_nothing_raised { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel) }
        assert_nothing_raised { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, Magick::BlueChannel) }
        assert_raise(TypeError) { @img.gaussian_blur_channel(0.0, 3.0, Magick::RedChannel, 2) }
        # sigma must be != 0.0
        assert_raise(Magick::ImageMagickError) { @img.gaussian_blur_channel(1.0, 0.0) }
    end
    
    def test_get_exif_by_entry
        assert_nothing_raised do
            res = @img.get_exif_by_entry
            assert_instance_of(Array, res)
        end
    end
    
    def test_get_exif_by_number
        assert_nothing_raised do
            res = @img.get_exif_by_number
            assert_instance_of(Hash, res)
        end
    end
    
    def test_get_pixels
        assert_nothing_raised do
            pixels = @img.get_pixels(0, 0, @img.columns, 1)
            assert_instance_of(Array, pixels)
            assert_equal(@img.columns, pixels.length)
            assert_block do
                pixels.all? { |p| p.is_a? Magick::Pixel }
            end
        end
        assert_raise(RangeError) { @img.get_pixels( 0,  0, -1, 1) }
        assert_raise(RangeError) { @img.get_pixels( 0,  0, @img.columns, -1) }
        assert_raise(RangeError) { @img.get_pixels( 0,  0, @img.columns+1, 1) }
        assert_raise(RangeError) { @img.get_pixels( 0,  0, @img.columns, @img.rows+1) }
    end
    
    def test_gray?
        gray = Magick::Image.new(20, 20) { self.background_color = 'gray50' }
        assert(gray.gray?)
        red = Magick::Image.new(20, 20) { self.background_color = 'red' }
        assert(!red.gray?)
    end
    
    def test_grayscale_pseudo_class
        # only supported on GraphicsMagick
        begin
            @img.grayscale_pseudo_class
        rescue NotImplementedError
            return
        end
        
        assert_nothing_raised do
            res = @img.grayscale_pseudo_class
            assert_instance_of(Magick::Image, res)
            assert_equal(Magick::PsuedoClass, res.class_type)
        end
        assert_nothing_raised { @img.grayscale_pseudo_class(false) }
        assert_raise(ArgumentError) { @img.grayscale_pseudo_class(false, 2) }
    end
    
    def test_implode
        assert_nothing_raised do
            res = @img.implode(0.5)
            assert_instance_of(Magick::Image, res)
        end
    end

    def test_import_pixels
        pixels = @img.export_pixels(0, 0, @img.columns, 1, "RGB")
        assert_nothing_raised do
            res = @img.import_pixels(0, 0, @img.columns, 1, "RGB", pixels)
            assert_same(@img, res)
        end
        assert_raise(ArgumentError) { @img.import_pixels(-1, 0, @img.columns, 1, "RGB", pixels) }
        assert_raise(ArgumentError) { @img.import_pixels(0, -1, @img.columns, 1, "RGB", pixels) }
        assert_raise(ArgumentError) { @img.import_pixels(0, 0, -1, 1, "RGB", pixels) }
        assert_raise(ArgumentError) { @img.import_pixels(0, 0, @img.columns, -1, "RGB", pixels) }
        
        # pixel array is too small
        assert_raise(ArgumentError) { @img.import_pixels(0, 0, @img.columns, 2, "RGB", pixels) }
    end
    
    def test_level
        assert_nothing_raised do
            res = @img.level
            assert_instance_of(Magick::Image, res)
        end
        assert_nothing_raised { @img.level(0.0) }
        assert_nothing_raised { @img.level(0.0, 1.0) }
        assert_nothing_raised { @img.level(0.0, 1.0, Magick::MaxRGB) }
        assert_raise(ArgumentError) { @img.level(0.0, 1.0, Magick::MaxRGB, 2) }
        assert_raise(TypeError) { @img.level('x') }
        assert_raise(TypeError) { @img.level(0.0, 'x') }
        assert_raise(TypeError) { @img.level(0.0, 1.0, 'x') }
    end
    
    def test_level_channel
        assert_raise(ArgumentError) { @img.level_channel }
        assert_nothing_raised do
            res = @img.level_channel(Magick::RedChannel)
            assert_instance_of(Magick::Image, res)
        end
        
        assert_nothing_raised { @img.level_channel(Magick::RedChannel, 0.0) }
        assert_nothing_raised { @img.level_channel(Magick::RedChannel, 0.0, 1.0) }
        assert_nothing_raised { @img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::MaxRGB) }
    
        assert_raise(ArgumentError) { @img.level_channel(Magick::RedChannel, 0.0, 1.0, Magick::MaxRGB, 2) }
        assert_raise(TypeError) { @img.level_channel(2) }
        assert_raise(TypeError) { @img.level_channel(Magick::RedChannel, 'x') }
        assert_raise(TypeError) { @img.level_channel(Magick::RedChannel, 0.0, 'x') }
        assert_raise(TypeError) { @img.level_channel(Magick::RedChannel, 0.0, 1.0, 'x') }
    end
    
    def test_magnify
    	assert_nothing_raised do
    		res = @img.magnify
    		assert_instance_of(Magick::Image, res)
    	end
    	
    	res = @img.magnify!
    	assert_same(@img, res)
    end
    
    def test_map
    	map = Magick::Image.read("netscape:").first
    	assert_nothing_raised do
    		res = @img.map(map)
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.map(map, true) }
    	assert_raise(NoMethodError) { @img.map(2) }
    	assert_raise(ArgumentError) { @img.map(map, true, 2) }
    	assert_raise(ArgumentError) { @img.map }
    end
    
    def test_matte_fill_to_border
    	assert_nothing_raised do
    		res = @img.matte_fill_to_border(@img.columns/2, @img.rows/2)
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.matte_fill_to_border(@img.columns, @img.rows) }
    	assert_raise(ArgumentError) { @img.matte_fill_to_border(@img.columns+1, @img.rows) }
    	assert_raise(ArgumentError) { @img.matte_fill_to_border(@img.columns, @img.rows+1) }
    end
    		
    def test_matte_floodfill
    	assert_nothing_raised do
    		res = @img.matte_floodfill(@img.columns/2, @img.rows/2)
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.matte_floodfill(@img.columns, @img.rows) }
    	assert_raise(ArgumentError) { @img.matte_floodfill(@img.columns+1, @img.rows) }
    	assert_raise(ArgumentError) { @img.matte_floodfill(@img.columns, @img.rows+1) }
    end
    		
    def test_matte_replace
    	assert_nothing_raised do
    		res = @img.matte_replace(@img.columns/2, @img.rows/2)
    		assert_instance_of(Magick::Image, res)
    	end
    end

	def test_matte_reset!
		assert_nothing_raised do
			res = @img.matte_reset!
			assert_same(@img, res)
		end
	end
    
    def test_median_filter
    	assert_nothing_raised do
    		res = @img.median_filter
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.median_filter(0.5) }
    	assert_raise(ArgumentError) { @img.median_filter(0.5, 'x') }
    	assert_raise(TypeError) { @img.median_filter('x') }
    end
    
    def test_minify
    	assert_nothing_raised do
    		res = @img.minify
    		assert_instance_of(Magick::Image, res)
    	end
    	
    	res = @img.minify!
    	assert_same(@img, res)
    end
    
    def test_modulate
    	assert_nothing_raised do
    		res = @img.modulate
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.modulate(0.5) }
    	assert_nothing_raised { @img.modulate(0.5, 0.5) }
    	assert_nothing_raised { @img.modulate(0.5, 0.5, 0.5) }
    	assert_raise(ArgumentError) { @img.modulate(0.5, 0.5, 0.5, 0.5) }
    	assert_raise(TypeError) { @img.modulate('x', 0.5, 0.5) }
    	assert_raise(TypeError) { @img.modulate(0.5, 'x', 0.5) }
    	assert_raise(TypeError) { @img.modulate(0.5, 0.5, 'x') }
    end
    
    def test_monochrome?
    	assert_block { @img.monochrome? }
    	@img.pixel_color(0,0, 'red')
    	assert_block { ! @img.monochrome? }
    end
    
    def test_motion_blur
    	assert_nothing_raised do
    		res = @img.motion_blur(1.0, 7.0, 180)
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_raise(ArgumentError) { @img.motion_blur(1.0, 0.0, 180) }
    	assert_nothing_raised { @img.motion_blur(1.0, -1.0, 180) }
    end
    
    def test_negate
    	assert_nothing_raised do
    		res = @img.negate
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.negate(true) }
    	assert_raise(ArgumentError) { @img.negate(true, 2) }
    end

	def test_negate_channel
		assert_nothing_raised do
			res = @img.negate_channel
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.negate_channel(true) }
		assert_nothing_raised { @img.negate_channel(true, Magick::RedChannel) }
		assert_nothing_raised { @img.negate_channel(true, Magick::RedChannel, Magick::BlueChannel) }
		assert_raise(TypeError) { @img.negate_channel(true, Magick::RedChannel, 2) }
	end
	
	def test_normalize
		assert_nothing_raised do
			res = @img.normalize
			assert_instance_of(Magick::Image, res)
			assert_not_same(@img, res)
		end
	end
	
	def test_normalize_channel
		assert_nothing_raised do
			res = @img.normalize_channel
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.normalize_channel(Magick::RedChannel) }
		assert_nothing_raised { @img.normalize_channel(Magick::RedChannel, Magick::BlueChannel) }
		assert_raise(TypeError) { @img.normalize_channel(Magick::RedChannel, 2) }
	end
    
end

if __FILE__ == $0
IMAGES_DIR = '../doc/ex/images'
FILES = Dir[IMAGES_DIR+'/Button_*.gif']
Test::Unit::UI::Console::TestRunner.run(Image2_UT)
end